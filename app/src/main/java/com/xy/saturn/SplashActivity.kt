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
