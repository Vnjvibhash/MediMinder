# MediMinder - Medicine Reminder

<p align="center">
  <img src="assets/images/mediminder.png?raw=true" alt="MediMinder Logo" height="400"/>
</p>

MediMinder is a Flutter-based mobile application designed to help users manage their medication schedules efficiently. It provides personalized medicine reminders, tracks dose history, and organizes medications by disease category with reliable notifications to promote medication adherence and improve health outcomes.

## Features
- Schedule personalized medicine reminders with dose and timing.
- Categorize medications by disease for organized management.
- Receive timely local notifications to never miss a dose.
- Track medication intake history including taken, missed, or skipped doses.
- Seamless data synchronization backed by Firebase Cloud Firestore.
- Clean, intuitive, and responsive Flutter UI suitable for all users.

## Getting Started
### Prerequisites
- Flutter SDK 3.8.1 or higher.
- Android Studio or Xcode (for Android/iOS builds).
- Firebase project configured with Firestore and Authentication enabled.

### Installation
1. Clone the repository:
```bash
git clone https://github.com/yourusername/mediminder.git
cd mediminder
```

2. Install dependencies:
```bash
flutter pub get
```
3. Set up Firebase for Android and iOS:
 - Add google-services.json in android/app/.
 - Add GoogleService-Info.plist in ios/Runner/.
 - Follow FlutterFire documentation for detailed setup.

4. Run the app:
```bash
flutter run
```
## Project Structure
```bash
└── lib
    ├── firebase_options.dart
    ├── firestore
        └── firestore_data_schema.dart
    ├── main.dart
    ├── providers
        └── medicine_provider.dart
    ├── repositories
        └── medicine_repository.dart
    ├── screens
        ├── auth
        │   ├── login_screen.dart
        │   └── signup_screen.dart
        ├── home
        │   ├── dashboard_tab.dart
        │   ├── history_tab.dart
        │   ├── home_screen.dart
        │   ├── profile_tab.dart
        │   └── reminders_tab.dart
        ├── patients
        │   └── patients_screen.dart
        ├── reminders
        │   ├── add_reminder_screen.dart
        │   └── edit_reminder_screen.dart
        └── splash_screen.dart
    ├── services
        ├── auth_service.dart
        └── notification_service.dart
    ├── theme.dart
    └── widgets
        ├── custom_button.dart
        ├── custom_text_field.dart
        ├── reminder_card.dart
        └── stats_card.dart
```

## Dependencies
- firebase_core
- cloud_firestore
- firebase_auth
- flutter_local_notifications
- provider (for state management)
- video_player (for background videos)
- Other Flutter essentials

## Permissions
- Internet access for Firebase.
- Local notifications permission.
- Background services for reminders.
- Device boot receiver to reschedule alarms.

## Contributing
Contributions are welcome! Feel free to submit issues or pull requests for enhancements, bug fixes, or documentation improvements.

## License
Licensed under the MIT License.

## Contact
Developed by Vivek Kumar
Email: vnjvibhash@gmail.com
Website: https://vivekajee.in
