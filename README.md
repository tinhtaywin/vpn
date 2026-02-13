# VLESS VPN Client

A production-ready Flutter VPN client with VLESS TCP Reality protocol support and a stunning neon-themed user interface.

## Features

- **VLESS Protocol Support**: Full implementation of VLESS TCP Reality protocol
- **Neon UI Theme**: Beautiful neon-themed interface with glowing effects
- **Split Tunneling**: Advanced app-level VPN control with bypass/allow modes
- **Traffic Statistics**: Real-time upload/download monitoring
- **Server Management**: Easy server configuration and management
- **Connection Status**: Live connection status with detailed information
- **Dark/Light Themes**: Multiple theme options available

## Screenshots

![Home Screen](screenshots/home.png)
![Server Configuration](screenshots/server-config.png)
![Split Tunneling](screenshots/split-tunneling.png)
![Settings](screenshots/settings.png)

## Installation

### Prerequisites

- Flutter 3.22.0 or higher
- Android SDK with API level 21 or higher
- Android Studio or VS Code with Flutter extension

### Setup Instructions

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/flutter-vless-vpn.git
   cd flutter-vless-vpn
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Android permissions:**
   The required VPN permissions are already configured in `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <uses-permission android:name="android.permission.INTERNET" />
   <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
   <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
   <uses-permission android:name="android.permission.VIBRATE" />
   ```

4. **Build and run:**
   ```bash
   flutter run
   ```

## Configuration

### Server Configuration

To configure a VLESS server:

1. Open the app and go to **Server Configuration**
2. Fill in the server details:
   - **Server Address**: Your VLESS server domain or IP
   - **Port**: Server port (usually 443)
   - **UUID**: Your VLESS user UUID
   - **Flow**: Connection flow (none or xtls-rprx-vision)
   - **Encryption**: Encryption method (none or zero)
   - **Fingerprint**: TLS fingerprint (chrome, firefox, safari, etc.)
   - **Public Key**: Reality public key (if using Reality)
   - **Short ID**: Reality short ID
   - **SNI**: Server Name Indication
   - **Spider-X**: Optional path for spider-x

3. **Test Connection**: Use the test button to verify your configuration
4. **Save**: Save the configuration to use it

### Example Server Configuration

```yaml
Server Address: example.com
Port: 443
UUID: 00000000-0000-0000-0000-000000000000
Flow: xtls-rprx-vision
Encryption: none
Fingerprint: chrome
Public Key: your-public-key-here
Short ID: your-short-id
SNI: example.com
Spider-X: (optional)
```

### Split Tunneling

Configure which apps should use the VPN:

1. Go to **Split Tunneling**
2. Toggle **Enable Split Tunneling**
3. Choose **Bypass Mode**:
   - **On**: Selected apps bypass VPN (use direct connection)
   - **Off**: Selected apps use VPN (others bypass)
4. Select the apps you want to control
5. **Save Selection**

## Development

### Project Structure

```
lib/
├── models/           # Data models
│   ├── server_config.dart
│   ├── vpn_status.dart
│   ├── app_info.dart
│   └── traffic_stats.dart
├── services/         # Business logic
│   ├── vpn_service.dart
│   ├── storage_service.dart
│   └── permission_service.dart
├── providers/        # State management
│   ├── vpn_provider.dart
│   └── settings_provider.dart
├── theme/            # UI theme
│   └── app_theme.dart
├── widgets/          # Reusable components
│   ├── connection_status_indicator.dart
│   ├── traffic_display.dart
│   ├── neon_button.dart
│   ├── neon_card.dart
│   ├── neon_text_field.dart
│   ├── loading_animation.dart
│   └── app_selector_item.dart
├── screens/          # App screens
│   ├── home_screen.dart
│   ├── server_config_screen.dart
│   ├── split_tunneling_screen.dart
│   └── settings_screen.dart
└── main.dart         # App entry point

android/
└── app/src/main/kotlin/
    └── com/example/flutter_vless_vpn/
        ├── VLESSVpnService.kt      # Android VPN service
        ├── VLESSProtocol.kt        # VLESS protocol implementation
        ├── MethodChannelHandler.kt # Flutter-Android communication
        ├── MainActivity.kt         # Main activity
        └── PermissionService.kt    # Permission handling
```

### Adding New Features

1. **Create Models**: Add new data models in `lib/models/`
2. **Implement Services**: Add business logic in `lib/services/`
3. **Update Providers**: Modify state management in `lib/providers/`
4. **Create Widgets**: Add reusable components in `lib/widgets/`
5. **Build Screens**: Create new screens in `lib/screens/`
6. **Update Theme**: Modify UI theme in `lib/theme/`

### Testing

Run the app on an Android device or emulator:

```bash
flutter run
```

For debugging, use:

```bash
flutter run --verbose
```

## Troubleshooting

### Common Issues

1. **VPN Permission Denied**
   - Ensure the app has VPN permissions
   - Check Android settings > Apps > [Your App] > Permissions

2. **Connection Failed**
   - Verify server configuration
   - Check internet connection
   - Test with different server settings

3. **Split Tunneling Not Working**
   - Ensure split tunneling is enabled
   - Check app selection
   - Restart VPN connection

4. **App Crashes on Launch**
   - Clear app data and cache
   - Reinstall the app
   - Check Android version compatibility

### Logs and Debugging

Enable debug logging in the app settings to get detailed connection logs.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support and questions:
- Create an issue on GitHub
- Join our Discord community
- Email: support@example.com

## Disclaimer

This app is for educational and testing purposes. Users are responsible for ensuring compliance with local laws and regulations when using VPN services.