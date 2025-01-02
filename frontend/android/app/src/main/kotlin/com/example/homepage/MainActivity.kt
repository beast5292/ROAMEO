import io.flutter.plugins.googlemaps.GoogleMapsPlugin

override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    GoogleMapsPlugin.registerWith(flutterEngine) // Register the plugin
}
