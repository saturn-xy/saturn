#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════╗
# ║          Saturn → GitHub Actions Setup Script           ║
# ║              github.com/saturn-xy/saturn                ║
# ╚══════════════════════════════════════════════════════════╝
set -e

# ── رنگ‌ها ────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

log()  { echo -e "${CYAN}${BOLD}[•]${RESET} $1"; }
ok()   { echo -e "${GREEN}${BOLD}[✓]${RESET} $1"; }
warn() { echo -e "${YELLOW}${BOLD}[!]${RESET} $1"; }
die()  { echo -e "${RED}${BOLD}[✗]${RESET} $1"; exit 1; }

GITHUB_USER="saturn-xy"
REPO_NAME="saturn"
REPO_DESC="Saturn Android App – Jetpack Compose"

echo -e "\n${BOLD}${CYAN}═══════════════════════════════════════${RESET}"
echo -e "${BOLD}  🪐  Saturn → GitHub Actions Setup${RESET}"
echo -e "${BOLD}${CYAN}═══════════════════════════════════════${RESET}\n"

# ────────────────────────────────────────────────────────────
# 1. التحقق من وجود Git
# ────────────────────────────────────────────────────────────
log "التحقق من Git..."
command -v git &>/dev/null || die "Git غير مثبّت. شغّل: pkg install git"
ok "Git موجود: $(git --version)"

# ────────────────────────────────────────────────────────────
# 2. التحقق من وجود GitHub CLI
# ────────────────────────────────────────────────────────────
log "التحقق من GitHub CLI (gh)..."
if ! command -v gh &>/dev/null; then
    warn "gh غير مثبّت. جاري التثبيت..."
    # Termux
    if command -v pkg &>/dev/null; then
        pkg install gh -y
    # Ubuntu/Debian
    elif command -v apt &>/dev/null; then
        sudo apt install gh -y
    else
        die "ثبّت gh يدوياً: https://cli.github.com"
    fi
fi
ok "GitHub CLI: $(gh --version | head -1)"

# ────────────────────────────────────────────────────────────
# 3. تسجيل الدخول
# ────────────────────────────────────────────────────────────
log "التحقق من تسجيل الدخول في GitHub..."
if ! gh auth status &>/dev/null; then
    warn "غير مسجّل الدخول. سيتم فتح المتصفح..."
    gh auth login --web --git-protocol https
fi
ok "مسجّل الدخول كـ $(gh api user --jq .login)"

# ────────────────────────────────────────────────────────────
# 4. التأكد أننا في مجلد المشروع الصحيح
# ────────────────────────────────────────────────────────────
log "التحقق من مجلد المشروع..."
[[ -f "gradlew" && -f "settings.gradle.kts" ]] || \
    die "شغّل السكربت من داخل مجلد مشروع Saturn (نفس مستوى gradlew)"
ok "مجلد المشروع صحيح"

# ────────────────────────────────────────────────────────────
# 5. إعداد Git
# ────────────────────────────────────────────────────────────
log "إعداد Git repository..."
git init -q
git config user.name  "saturn-xy"
git config user.email "saturn-xy@users.noreply.github.com"

# ── .gitignore ───────────────────────────────────────────
log "إنشاء .gitignore..."
cat > .gitignore << 'GITIGNORE'
# Gradle
.gradle/
build/
**/build/
gradle-app.setting

# Android
local.properties
*.jks
*.keystore

# IDE
.idea/
*.iml
*.iws
*.ipr
.DS_Store

# Generated
app/src/main/assets/dexopt/
app/src/main/assets/webkit/

# Outputs
*.apk
*.aab
*.ap_
GITIGNORE

ok ".gitignore جاهز"

# ────────────────────────────────────────────────────────────
# 6. إنشاء GitHub Actions Workflow
# ────────────────────────────────────────────────────────────
log "إنشاء GitHub Actions workflow..."
mkdir -p .github/workflows
cat > .github/workflows/build.yml << 'WORKFLOW'
name: Build Saturn APK

on:
  push:
    branches: [ main, master ]
  pull_request:
    branches: [ main, master ]
  workflow_dispatch:

jobs:
  build:
    name: Build APK
    runs-on: ubuntu-latest

    steps:
      - name: ⬇️ Checkout repo
        uses: actions/checkout@v4

      - name: ☕ Setup JDK 17
        uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'
          cache: gradle

      - name: 🤖 Setup Android SDK
        uses: android-actions/setup-android@v3

      - name: 🔑 Grant execute permission to gradlew
        run: chmod +x gradlew

      - name: 🔨 Build Debug APK
        run: ./gradlew assembleDebug --no-daemon

      - name: 📦 Upload Debug APK
        uses: actions/upload-artifact@v4
        with:
          name: Saturn-debug
          path: app/build/outputs/apk/debug/*.apk
          retention-days: 30

      # ─── Release build (needs keystore secrets) ───────────
      - name: 🔐 Decode Keystore
        if: ${{ secrets.KEYSTORE_BASE64 != '' }}
        run: |
          echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 -d > app/keystore.jks

      - name: 🚀 Build Release APK (signed)
        if: ${{ secrets.KEYSTORE_BASE64 != '' }}
        env:
          KEYSTORE_PATH:  app/keystore.jks
          KEY_ALIAS:      ${{ secrets.KEY_ALIAS }}
          KEY_PASSWORD:   ${{ secrets.KEY_PASSWORD }}
          STORE_PASSWORD: ${{ secrets.STORE_PASSWORD }}
        run: ./gradlew assembleRelease --no-daemon

      - name: 📦 Upload Release APK
        if: ${{ secrets.KEYSTORE_BASE64 != '' }}
        uses: actions/upload-artifact@v4
        with:
          name: Saturn-release
          path: app/build/outputs/apk/release/*.apk
          retention-days: 90
WORKFLOW

ok "Workflow جاهز في .github/workflows/build.yml"

# ────────────────────────────────────────────────────────────
# 7. Commit أولي
# ────────────────────────────────────────────────────────────
log "إضافة الملفات وعمل Commit..."
git add -A
git commit -m "🪐 Initial commit – Saturn Android App

- Jetpack Compose + Material3
- Splash screen (androidx.core.splashscreen)
- AGP 8.10.1 | Kotlin 2.1.21 | Gradle 8.11.1
- GitHub Actions: auto-build APK on push" -q
ok "Commit جاهز"

# ────────────────────────────────────────────────────────────
# 8. إنشاء المستودع على GitHub
# ────────────────────────────────────────────────────────────
log "إنشاء مستودع GitHub: ${GITHUB_USER}/${REPO_NAME}..."

# التحقق إن المستودع موجود مسبقاً
if gh repo view "${GITHUB_USER}/${REPO_NAME}" &>/dev/null; then
    warn "المستودع موجود مسبقاً – سيتم الدفع إليه فقط"
else
    gh repo create "${GITHUB_USER}/${REPO_NAME}" \
        --public \
        --description "${REPO_DESC}" \
        --source=. \
        --remote=origin \
        --push
    ok "تم إنشاء المستودع بنجاح ✓"
fi

# ────────────────────────────────────────────────────────────
# 9. Push
# ────────────────────────────────────────────────────────────
log "رفع الكود إلى GitHub..."
BRANCH=$(git branch --show-current)
git remote set-url origin "https://github.com/${GITHUB_USER}/${REPO_NAME}.git" 2>/dev/null || \
    git remote add origin "https://github.com/${GITHUB_USER}/${REPO_NAME}.git"
git push -u origin "${BRANCH}" --force-with-lease
ok "تم الرفع بنجاح!"

# ────────────────────────────────────────────────────────────
# 10. تفعيل أول Run
# ────────────────────────────────────────────────────────────
log "تشغيل GitHub Actions يدوياً..."
sleep 2
gh workflow run build.yml --repo "${GITHUB_USER}/${REPO_NAME}" 2>/dev/null && \
    ok "Workflow شغّال!" || \
    warn "سيشتغل تلقائياً عند أول push – لا تقلق"

# ────────────────────────────────────────────────────────────
# 🎉 ملخص
# ────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}${GREEN}════════════════════════════════════════${RESET}"
echo -e "${BOLD}${GREEN}  🎉 كل شيء جاهز!${RESET}"
echo -e "${BOLD}${GREEN}════════════════════════════════════════${RESET}"
echo ""
echo -e "  ${BOLD}المستودع:${RESET}  https://github.com/${GITHUB_USER}/${REPO_NAME}"
echo -e "  ${BOLD}Actions:${RESET}   https://github.com/${GITHUB_USER}/${REPO_NAME}/actions"
echo -e "  ${BOLD}APK:${RESET}       Actions → آخر Run → Artifacts → Saturn-debug"
echo ""
echo -e "${YELLOW}${BOLD}  💡 لبناء Release APK (موقّع) أضف هذه الـ Secrets:${RESET}"
echo -e "     KEYSTORE_BASE64  ← base64 -w0 your.jks"
echo -e "     KEY_ALIAS        ← اسم الـ alias"
echo -e "     KEY_PASSWORD     ← كلمة مرور المفتاح"
echo -e "     STORE_PASSWORD   ← كلمة مرور الـ keystore"
echo -e "     من: Settings → Secrets → Actions"
echo ""
