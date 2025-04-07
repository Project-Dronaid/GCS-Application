package com.example.gcs_application;

import android.os.Bundle;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import androidx.annotation.NonNull;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL_NAME = "com.example.gcs_application/channel";
    private DroneController droneController;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        MethodChannel channel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL_NAME);
        droneController = new DroneController(this, channel); // 👈 pass channel here

        channel.setMethodCallHandler((call, result) -> {
            switch (call.method) {
                case "connectDrone":
                    droneController.startTelemetryUpdates();
                    result.success("Drone connected");
                    break;
                case "toggleArmDisarm":
                    droneController.toggleArmDisarm();
                    result.success("Toggled");
                    break;
                default:
                    result.notImplemented();
            }
        });
    }
}
