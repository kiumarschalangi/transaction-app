# Transaction App

A retro-themed Flutter app for sending HTTP requests and viewing responses in a terminal-style interface.

## Overview

This project is built with Flutter and demonstrates a retro terminal UI for composing and executing HTTP requests. It uses `flutter_bloc` for state management and `http` for networking.

The app launches into a retro terminal screen where the user can:

- Enter a request URL
- Select an HTTP method (`GET`, `POST`, `PUT`, `PATCH`, `DELETE`)
- Add or edit a JSON request body for body-based methods
- Send the request and inspect the response logs
- Clear the terminal output

## Key Features

- Retro terminal UI with green-on-black styling
- HTTP method selection
- Request body editor for `POST`, `PUT`, and `PATCH`
- Response logging with status, headers, and body
- Timeout handling and error display
- Built with `flutter_bloc`, `http`, and `equatable`

## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK (bundled with Flutter)
- A connected device or emulator

### Run the app

```bash
flutter pub get
flutter run
```

## Screenshots

> Add screenshot files to the `screenshots/` folder and update these links if needed.

![Transfer Money Screen](screenshots/transfer_money_screen.png)

![Request Body Dialog](screenshots/request_body_dialog.png)

## Project Structure

- `lib/main.dart` - App entrypoint and theme configuration
- `lib/screens/transfer_money/transfer_money_screen.dart` - Main UI and request workflow
- `lib/screens/transfer_money/cubit/transfer_money_cubit.dart` - Request handling and state management
- `lib/screens/transfer_money/cubit/transfer_money_state.dart` - App state model
- `lib/components/terminal_window_circular_button.dart` - Terminal-style UI button
- `lib/components/blinking_cursor/` - Terminal prompt cursor effect
- `lib/constants/` - Shared colors, spacing, enums, and strings

## Dependencies

- `flutter_bloc` - State management
- `http` - HTTP client
- `equatable` - Value equality for state objects

## Notes

- The app currently launches directly to the transfer request screen.
- The UI is styled with a custom `Courier` font and a dark terminal theme.

## License

No license specified.
