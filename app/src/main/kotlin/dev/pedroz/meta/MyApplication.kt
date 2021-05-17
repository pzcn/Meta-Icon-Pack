package dev.pedroz.meta

import android.annotation.SuppressLint
import dev.jahir.frames.ui.FramesApplication

class MyApplication : FramesApplication() {
    @SuppressLint("MissingSuperCall")
    override fun onCreate() {
        super.onCreate()
    }
}