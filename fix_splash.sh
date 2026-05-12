#!/usr/bin/env bash
set -e

# ── 1. Saturn vector (نظيف بدون خلفية مربعة) ─────────────────
cat > app/src/main/res/drawable/ic_saturn_clean.xml << 'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="200dp"
    android:height="200dp"
    android:viewportWidth="200"
    android:viewportHeight="200">

    <!-- حلقة خلفية (وراء الكوكب) -->
    <path
        android:fillColor="#00000000"
        android:strokeColor="#3A7FA8"
        android:strokeWidth="13"
        android:strokeLineCap="round"
        android:pathData="M12,100 C55,64 145,64 188,100"/>

    <!-- جسم الكوكب -->
    <path
        android:fillColor="#1A3E5C"
        android:pathData="M40,100 A60,60 0 1 0 160,100 A60,60 0 1 0 40,100 Z"/>

    <!-- طبقة فاتحة علوية -->
    <path
        android:fillColor="#234F6E"
        android:pathData="M56,76 Q100,56 144,76 Q134,46 100,43 Q66,46 56,76 Z"/>

    <!-- شريط داكن -->
    <path
        android:fillColor="#112838"
        android:pathData="M44,107 Q100,99 156,107 Q156,117 100,114 Q44,117 44,107 Z"/>

    <!-- بريق صغير -->
    <path
        android:fillColor="#4A90B8"
        android:pathData="M70,62 Q76,56 82,60 Q78,68 70,62 Z"/>

    <!-- حلقة أمامية (أمام الكوكب) -->
    <path
        android:fillColor="#00000000"
        android:strokeColor="#3A7FA8"
        android:strokeWidth="13"
        android:strokeLineCap="round"
        android:pathData="M12,100 C55,136 145,136 188,100"/>

</vector>
EOF

# ── 2. Layout الـ Splash ───────────────────────────────────────
mkdir -p app/src/main/res/layout
cat > app/src/main/res/layout/activity_splash.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<FrameLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="#000000">

    <ImageView
        android:id="@+id/iv_saturn"
        android:layout_width="220dp"
        android:layout_height="220dp"
        android:layout_gravity="center"
        android:src="@drawable/ic_saturn_clean"
        android:contentDescription="@null" />

</FrameLayout>
EOF

# ── 3. SplashActivity ──────────────────────────────────────────
cat > app/src/main/java/com/xy/saturn/SplashActivity.kt << 'EOF'
package com.xy.saturn

import android.animation.ObjectAnimator
import android.animation.ValueAnimator
import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.animation.LinearInterpolator
import android.widget.ImageView
import androidx.activity.ComponentActivity

class SplashActivity : ComponentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_splash)

        val saturn = findViewById<ImageView>(R.id.iv_saturn)

        ObjectAnimator.ofFloat(saturn, "rotation", 0f, 360f).apply {
            duration          = 3600
            interpolator      = LinearInterpolator()
            repeatCount       = ValueAnimator.INFINITE
        }.start()

        Handler(Looper.getMainLooper()).postDelayed({
            startActivity(Intent(this, MainActivity::class.java))
            finish()
        }, 2600)
    }
}
EOF

# ── 4. Theme (خلفية سوداء خالصة، بدون عنوان) ─────────────────
cat > app/src/main/res/values/themes.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="Theme.Saturn" parent="android:Theme.Material.Light.NoTitleBar.Fullscreen">
        <item name="android:windowBackground">@android:color/black</item>
        <item name="android:statusBarColor">@android:color/black</item>
        <item name="android:navigationBarColor">@android:color/black</item>
        <item name="android:windowLightStatusBar">false</item>
    </style>

    <style name="Theme.Saturn.Splash" parent="Theme.Saturn"/>
</resources>
EOF

cat > app/src/main/res/values-night/themes.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="Theme.Saturn" parent="android:Theme.Material.Light.NoTitleBar.Fullscreen">
        <item name="android:windowBackground">@android:color/black</item>
        <item name="android:statusBarColor">@android:color/black</item>
        <item name="android:navigationBarColor">@android:color/black</item>
        <item name="android:windowLightStatusBar">false</item>
    </style>

    <style name="Theme.Saturn.Splash" parent="Theme.Saturn"/>
</resources>
EOF

# ── 5. AndroidManifest ─────────────────────────────────────────
cat > app/src/main/AndroidManifest.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <application
        android:allowBackup="true"
        android:icon="@mipmap/ic_launcher"
        android:label="@string/app_name"
        android:roundIcon="@mipmap/ic_launcher_round"
        android:supportsRtl="true"
        android:theme="@style/Theme.Saturn">

        <activity
            android:name=".SplashActivity"
            android:theme="@style/Theme.Saturn.Splash"
            android:screenOrientation="portrait"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>

        <activity
            android:name=".MainActivity"
            android:theme="@style/Theme.Saturn"
            android:screenOrientation="portrait"
            android:exported="false"/>

    </application>

</manifest>
EOF

# ── 6. Push ────────────────────────────────────────────────────
git add -A
git commit -m "feat: splash - saturn rotation clean no bg"
git push
