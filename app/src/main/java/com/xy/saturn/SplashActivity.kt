package com.xy.saturn

import android.content.Intent
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.Spring
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.spring
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.size
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.draw.scale
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.dp
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlin.math.PI
import kotlin.math.sin
import kotlin.random.Random

private data class Star(
    val x: Float,
    val y: Float,
    val radius: Float,
    val baseAlpha: Float,
    val phaseOffset: Float,
)

class SplashActivity : ComponentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        installSplashScreen()
        setContent {
            SplashScreen(
                onFinished = {
                    startActivity(Intent(this, MainActivity::class.java))
                    @Suppress("DEPRECATION")
                    overridePendingTransition(0, 0)
                    finish()
                }
            )
        }
    }
}

@Composable
private fun SplashScreen(onFinished: () -> Unit) {

    val iconAlpha   = remember { Animatable(0f) }
    val iconScale   = remember { Animatable(0.38f) }
    val screenAlpha = remember { Animatable(1f) }

    val infinite = rememberInfiniteTransition(label = "splash")

    val rotation by infinite.animateFloat(
        initialValue  = 0f,
        targetValue   = 360f,
        animationSpec = infiniteRepeatable(
            animation = tween(durationMillis = 18_000, easing = LinearEasing),
        ),
        label = "rotation",
    )

    val glowAlpha by infinite.animateFloat(
        initialValue  = 0.16f,
        targetValue   = 0.50f,
        animationSpec = infiniteRepeatable(
            animation  = tween(durationMillis = 2800, easing = FastOutSlowInEasing),
            repeatMode = RepeatMode.Reverse,
        ),
        label = "glowAlpha",
    )

    val glowScale by infinite.animateFloat(
        initialValue  = 0.80f,
        targetValue   = 1.14f,
        animationSpec = infiniteRepeatable(
            animation  = tween(durationMillis = 2800, easing = FastOutSlowInEasing),
            repeatMode = RepeatMode.Reverse,
        ),
        label = "glowScale",
    )

    val twinklePhase by infinite.animateFloat(
        initialValue  = 0f,
        targetValue   = (2.0 * PI).toFloat(),
        animationSpec = infiniteRepeatable(
            animation = tween(durationMillis = 5_000, easing = LinearEasing),
        ),
        label = "twinkle",
    )

    val stars = remember {
        List(95) {
            Star(
                x           = Random.nextFloat(),
                y           = Random.nextFloat(),
                radius      = Random.nextFloat() * 1.8f + 0.4f,
                baseAlpha   = Random.nextFloat() * 0.55f + 0.12f,
                phaseOffset = Random.nextFloat() * (2.0 * PI).toFloat(),
            )
        }
    }

    LaunchedEffect(Unit) {
        launch {
            iconAlpha.animateTo(
                targetValue   = 1f,
                animationSpec = tween(durationMillis = 1000, easing = FastOutSlowInEasing),
            )
        }
        iconScale.animateTo(
            targetValue   = 1f,
            animationSpec = spring(
                dampingRatio = Spring.DampingRatioMediumBouncy,
                stiffness    = Spring.StiffnessMediumLow,
            ),
        )
        delay(2_100)
        screenAlpha.animateTo(
            targetValue   = 0f,
            animationSpec = tween(durationMillis = 580, easing = FastOutSlowInEasing),
        )
        onFinished()
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .alpha(screenAlpha.value)
            .background(Color.Black),
        contentAlignment = Alignment.Center,
    ) {

        Canvas(modifier = Modifier.fillMaxSize()) {
            stars.forEach { star ->
                val sinVal = sin(twinklePhase + star.phaseOffset)
                val a = (star.baseAlpha * (0.45f + 0.55f * sinVal)).coerceIn(0f, 1f)
                drawCircle(
                    color  = Color.White.copy(alpha = a),
                    radius = star.radius,
                    center = Offset(star.x * size.width, star.y * size.height),
                )
            }
        }

        Canvas(
            modifier = Modifier
                .size(340.dp)
                .scale(glowScale),
        ) {
            val center = Offset(size.width / 2f, size.height / 2f)
            val radius = size.minDimension / 2f
            drawCircle(
                brush = Brush.radialGradient(
                    colors = listOf(
                        Color(0xFF88CCFF).copy(alpha = glowAlpha * 0.85f),
                        Color(0xFF2277AA).copy(alpha = glowAlpha * 0.40f),
                        Color.Transparent,
                    ),
                    center = center,
                    radius = radius,
                ),
                radius = radius,
                center = center,
            )
        }

        Image(
            painter            = painterResource(id = R.drawable.ic_app),
            contentDescription = null,
            modifier           = Modifier
                .size(215.dp)
                .alpha(iconAlpha.value)
                .scale(iconScale.value)
                .rotate(rotation),
        )
    }
}
