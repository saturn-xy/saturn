package com.xy.saturn.ui.theme

import android.os.Build
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable

private val LightColors = lightColorScheme(
    background   = White,
    surface      = White,
    onBackground = Black,
    onSurface    = Black,
    primary      = Accent,
    onPrimary    = White,
)

private val DarkColors = darkColorScheme(
    background   = Black,
    surface      = Black,
    onBackground = White,
    onSurface    = White,
    primary      = Accent,
    onPrimary    = White,
)

@Composable
fun SaturnTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit
) {
    val colorScheme = if (darkTheme) DarkColors else LightColors

    MaterialTheme(
        colorScheme = colorScheme,
        typography  = Typography,
        content     = content
    )
}
