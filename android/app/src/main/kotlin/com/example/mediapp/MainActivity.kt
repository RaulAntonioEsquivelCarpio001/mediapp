package com.example.mediapp

import android.content.Intent
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Maneja intents cuando se abre desde una notificación fullscreen
        intent?.let {
            Log.d("MediApp", "Intent recibido en onCreate: $it")
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)

        // Maneja intents cuando app ya está abierta
        Log.d("MediApp", "Intent recibido en onNewIntent: $intent")
    }
}
