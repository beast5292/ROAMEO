package com.example.homepage // Use your actual package name

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity: FlutterFragmentActivity() {
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // GoogleMapsPlugin is now automatically registered by Flutter's auto-registration mechanism.
        // No need to manually call registerWith.
    }
}
