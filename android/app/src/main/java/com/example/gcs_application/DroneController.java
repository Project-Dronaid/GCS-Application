package com.example.gcs_application;


import io.*;
import android.os.*;
import java.io.IOException;
import java.net.Socket;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.util.*;
import android.util.Log;
import io.dronefleet.mavlink.*;
import io.dronefleet.mavlink.common.*;
import io.dronefleet.mavlink.minimal.*;
import io.dronefleet.mavlink.util.*;
import android.content.Context;
import io.flutter.plugin.common.MethodChannel;


public  class DroneController {
    private Context context;

    private final MethodChannel channel;

    public DroneController(Context context, MethodChannel channel) {
        this.context = context;
        this.channel = channel;
    }

    private static final String TAG = "DroneController"; // Tag to identify the source of the log message
    private static final String drone_ip_address = "10.0.2.2";
    private static final int drone_port = 5762;

    private MavlinkConnection connection;
    private final int system_id = 1;
    private final int component_id = 0;
    private final int message_id = 0;
    private final ExecutorService executorArm = Executors.newSingleThreadExecutor();

    private final Handler handler = new Handler(Looper.getMainLooper());

    private boolean isArmed = false;  // Toggle state


    private boolean isTaskRunning = false;

    private boolean isDroneArmed = false;  // Track armed state
    private ScheduledExecutorService keepAliveExecutor;  // ✅ Correct type

    public void startTelemetryUpdates() {
        Log.d(TAG, "Connecting to drone...");
        new Thread(() -> {
            try {
                Socket socket = new Socket(drone_ip_address, drone_port);
                connection = MavlinkConnection.create(socket.getInputStream(), socket.getOutputStream());
                Log.d(TAG, "Connection successful");
                requestDataStream(33, 5);    // GPS
                requestDataStream(24, 5);    // Altitude
                requestDataStream(147, 5);   // Battery

                while (true) {
                    MavlinkMessage<?> message = connection.next();

                    if (message.getPayload() instanceof GlobalPositionInt) {
                        processGPSAltitude(message);
                    }

                    if (message.getPayload() instanceof BatteryStatus) {
                        processBatteryStatus(message);
                    }

                    if (message.getPayload() instanceof CommandAck) {
                        CommandAck ack = (CommandAck) message.getPayload();

                        if (ack.command().value() == 400) {
                            handler.post(() -> {
                                Integer result = ack.result().value();

                                if (result != null) {
                                    String toastMsg = "";
                                    switch (result) {
                                        case 0:
                                            Log.d(TAG, "Arm/Disarm Command Accepted!");
                                            toastMsg = isArmed ? "Drone Armed!" : "Drone Disarmed!";
                                            break;
                                        case 1:
                                            Log.e(TAG, "Command Temporarily Rejected!");
                                            toastMsg = "Command Temporarily Rejected!";
                                            break;
                                        case 2:
                                            Log.e(TAG, "Command Denied! Check pre-arm status.");
                                            toastMsg = "Command Denied! Check pre-arm status.";
                                            break;
                                        case 3:
                                            Log.e(TAG, "Command Unsupported!");
                                            toastMsg = "Command Unsupported!";
                                            break;
                                        default:
                                            Log.e(TAG, "Failed with result: " + result);
                                            toastMsg = "Failed: " + result;
                                            break;
                                    }
                                    if (!toastMsg.isEmpty()) {
                                        channel.invokeMethod("showToast", toastMsg);
                                    }
                                } else {
                                    Log.e(TAG, "No result received in CommandAck!");
                                }
                            });
                        }
                    }
                }

            } catch (IOException e) {
                e.printStackTrace();
                Log.d(TAG, "Connection Error: " + e.toString());
            }
        }).start();
    }

    // request data stream
    public void requestDataStream(int messageId, int frequency) {
        try {
            CommandLong command = CommandLong.builder()
                    .targetSystem(system_id)
                    .targetComponent(component_id)
                    .command(MavCmd.MAV_CMD_SET_MESSAGE_INTERVAL)
                    .param1(messageId)
                    .param2(1000000 / frequency)
                    .build();

            connection.send1(system_id, component_id, command);
            Log.d(TAG, "Requested message: " + messageId);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public void processGPSAltitude(MavlinkMessage<?> message) {
        if (message.getPayload() instanceof GlobalPositionInt) {
            GlobalPositionInt gpsMessage = (GlobalPositionInt) message.getPayload();

            double latitude = gpsMessage.lat() / 1E7;
            double longitude = gpsMessage.lon() / 1E7;
            double altitude = gpsMessage.alt() / 1000.0;
            double relAlt = gpsMessage.relativeAlt() / 1000.0; // in meters
            double vx = gpsMessage.vx() / 100.0;
            double vy = gpsMessage.vy() / 100.0;
            double vz = gpsMessage.vz() / 100.0;
            double heading = gpsMessage.hdg() != 65535 ? gpsMessage.hdg() / 100.0 : -1; // -1 = unknown

            double speed = Math.sqrt(vx * vx + vy * vy); // horizontal speed

            String gpsInfo = "GPS: Lat=" + latitude + ", Lon=" + longitude;
            String altitudeInfo = "Altitude: " + altitude + " m";

            Log.d(TAG, gpsInfo);
            Log.d(TAG, altitudeInfo);

            handler.post(() -> {
                Map<String, Object> data= new HashMap<>();
                data.put("latitude", latitude);
                data.put("longitude", longitude);
                data.put("altitude", altitude);
                data.put("relativeAltitude", relAlt);
                data.put("speed", speed);
                data.put("heading", heading);

                channel.invokeMethod("updateTelemetry", data);
            });
        }
    }

    public void processBatteryStatus(MavlinkMessage<?> message) {
        if (message.getPayload() instanceof BatteryStatus) {
            BatteryStatus batteryMessage = (BatteryStatus) message.getPayload();

            int voltage = batteryMessage.voltages().get(0) / 1000;
            int batteryRemaining = batteryMessage.batteryRemaining();

            String batteryInfo = "Battery: " + voltage + "V, " + batteryRemaining + "%";

//            handler.post(() -> batteryTextView.setText(batteryInfo));
        }
    }


    public void toggleArmDisarm() {
        Log.d(TAG, "Inside function");

        CommandLong command = CommandLong.builder()
                .targetSystem(system_id)
                .targetComponent(component_id)
                .command(MavCmd.MAV_CMD_COMPONENT_ARM_DISARM)
                .param1(isArmed ? 0 : 1)
                .param2(0)
                .build();

        ExecutorService executor = Executors.newSingleThreadExecutor();
        executor.execute(() -> {
            if (connection != null) {
                try {
                    connection.send1(system_id, component_id, command);
                    Log.d(TAG, "Command sent successfully.");

                    isArmed = !isArmed;

                    handler.post(() -> {
                        if (isArmed) {
//                            startKeepAlive();
//                            arm_btn.setText("Disarm");
//                            armTextView.setText("Armed");
                            channel.invokeMethod("showToast", "Drone Armed!");
                        } else {
//                            stopKeepAlive();
//                            arm_btn.setText("Arm");
//                            armTextView.setText("Disarmed");
                            channel.invokeMethod("showToast", "Drone Disarmed!");
                        }
                    });

                } catch (IOException e) {
                    Log.e(TAG, "Failed to send command: " + e.getMessage());
                    e.printStackTrace();
                    handler.post(() ->channel.invokeMethod("showToast", "Failed to send command!"));
                }
            } else {
                Log.e(TAG, "Connection is null!");
                handler.post(() -> channel.invokeMethod("showToast", "Drone connection not established!"));
            }
        });
    }

    public void startMission() {
        Log.d(TAG, "Starting Mission...");

        ExecutorService executor = Executors.newSingleThreadExecutor();
        executor.execute(() -> {
            if (connection != null) {
                try {
                    CommandLong setMode = CommandLong.builder()
                            .targetSystem(system_id)
                            .targetComponent(component_id)
                            .command(MavCmd.MAV_CMD_DO_SET_MODE)
                            .param1(1)
                            .param2(Modes.AUTO.getModeId())
                            .build();
                    connection.send1(system_id, component_id, setMode);
                    Log.d(TAG, "Switched to AUTO mode.");

                    CommandLong missionStart = CommandLong.builder()
                            .targetSystem(system_id)
                            .targetComponent(component_id)
                            .command(MavCmd.MAV_CMD_MISSION_START)
                            .param1(0)
                            .param2(0)
                            .build();
                    connection.send1(system_id, component_id, missionStart);
                    Log.d(TAG, "Mission started.");

                    handler.post(() -> channel.invokeMethod("showToast", "Mission started!"));

                } catch (IOException e) {
                    Log.e(TAG, "Failed to start mission: " + e.getMessage());
                    handler.post(() -> channel.invokeMethod("showToast", "Failed to start mission!"));
                }
            } else {
                Log.e(TAG, "Connection is null!");
                handler.post(() ->channel.invokeMethod("showToast", "Drone not connected!"));
            }
        });
    }

    public void abortMission() {
        Log.d(TAG, "Aborting Mission...");

        ExecutorService executor = Executors.newSingleThreadExecutor();
        executor.execute(() -> {
            if (connection != null) {
                try {
                    CommandLong abortCommand = CommandLong.builder()
                            .targetSystem(system_id)
                            .targetComponent(component_id)
                            .command(MavCmd.MAV_CMD_DO_SET_MODE)
                            .param1(1)
                            .param2(Modes.LOITER.getModeId())
                            .build();

                    connection.send1(system_id, component_id, abortCommand);
                    Log.d(TAG, "Mission aborted (LOITER mode).");

                    handler.post(() -> channel.invokeMethod("showToast", "Mission Aborted!"));

                } catch (IOException e) {
                    Log.e(TAG, "Failed to abort mission: " + e.getMessage());
                    handler.post(() -> channel.invokeMethod("showToast", "Failed to abort mission!"));
                }
            } else {
                Log.e(TAG, "Connection is null!");
                handler.post(() -> channel.invokeMethod("showToast", "Drone not connected!"));
            }
        });
    }


    public void returnToLaunch() {
        Log.d(TAG, "Returning to Launch...");

        ExecutorService executor = Executors.newSingleThreadExecutor();
        executor.execute(() -> {
            if (connection != null) {
                try {
                    CommandLong rtlCommand = CommandLong.builder()
                            .targetSystem(system_id)
                            .targetComponent(component_id)
                            .command(MavCmd.MAV_CMD_DO_SET_MODE)
                            .param1(1)
                            .param2(Modes.RTL.getModeId())
                            .build();

                    connection.send1(system_id, component_id, rtlCommand);
                    Log.d(TAG, "Return-to-launch triggered.");

                    handler.post(() -> channel.invokeMethod("showToast", "Returning to Launch!"));

                } catch (IOException e) {
                    Log.e(TAG, "Failed to trigger RTL: " + e.getMessage());
                    handler.post(() -> channel.invokeMethod("showToast", "Failed to trigger RTL!"));
                }
            } else {
                Log.e(TAG, "Connection is null!");
                handler.post(() -> channel.invokeMethod("showToast", "Drone not connected!"));
            }
        });
    }

    public void changeFlightMode(String modeName) {
        int modeId;

        switch (modeName) {
            case "STABILIZE":
                modeId = Modes.STABILIZE.getModeId();
                break;
            case "ALT_HOLD":
                modeId = Modes.LOITER.getModeId();
                break;
            case "GUIDED":
                modeId = Modes.GUIDED.getModeId();
                break;
            case "LOITER":
                modeId = Modes.LOITER.getModeId();
                break;
            case "AUTO":
                modeId = Modes.AUTO.getModeId();
                break;
            default:
                Log.e(TAG, "Unknown mode: " + modeName);
                channel.invokeMethod("showToast", "Invalid mode selected!");
                return;
        }

        ExecutorService executor = Executors.newSingleThreadExecutor();
        executor.execute(() -> {
            if (connection != null) {
                try {
                    CommandLong modeCommand = CommandLong.builder()
                            .targetSystem(system_id)
                            .targetComponent(component_id)
                            .command(MavCmd.MAV_CMD_DO_SET_MODE)
                            .param1(1)
                            .param2(modeId)
                            .build();

                    connection.send1(system_id, component_id, modeCommand);
                    Log.d(TAG, "Mode changed to: " + modeName);

                    handler.post(() -> channel.invokeMethod("showToast", "Mode set to " + modeName));

                } catch (IOException e) {
                    Log.e(TAG, "Failed to change mode: " + e.getMessage());
                    handler.post(() ->channel.invokeMethod("showToast", "Failed to change mode!"));
                }
            } else {
                Log.e(TAG, "Connection is null!");
                handler.post(() -> channel.invokeMethod("showToast", "Drone not connected!"));
            }
        });
    }

    public void landDrone() {
        Log.d(TAG, "Triggering Landing...");

        ExecutorService executor = Executors.newSingleThreadExecutor();
        executor.execute(() -> {
            if (connection != null) {
                try {
                    CommandLong landCommand = CommandLong.builder()
                            .targetSystem(system_id)
                            .targetComponent(component_id)
                            .command(MavCmd.MAV_CMD_DO_SET_MODE)
                            .param1(1)
                            .param2(Modes.LAND.getModeId())
                            .build();

                    connection.send1(system_id, component_id, landCommand);
                    Log.d(TAG, "Landing triggered.");

                    handler.post(() ->channel.invokeMethod("showToast", "Drone Landing..."));

                } catch (IOException e) {
                    Log.e(TAG, "Failed to trigger landing: " + e.getMessage());
                    handler.post(() -> channel.invokeMethod("showToast", "Failed to trigger landing!"));
                }
            } else {
                Log.e(TAG, "Connection is null!");
                handler.post(() ->channel.invokeMethod("showToast", "Drone not connected!"));
            }
        });
    }

    public enum Modes {
        STABILIZE(0),
        AUTO(3),
        GUIDED(4),
        LOITER(5),
        RTL(6),
        LAND(9),
        BRAKE(17),
        GUIDED_NO_GPS(20),
        SMART_RTL(21),
        ZIGZAG(24),
        AUTO_RTL(27);

        private final int mode_id;

        Modes (int mode_id) {
            this.mode_id = mode_id;
        }

        public int getModeId() {
            return this.mode_id;
        }
    }
}