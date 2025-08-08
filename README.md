# Performance Tracker Mobile App - Installation Guide 📱

## Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (2.17.0 or higher)
- Android Studio / VS Code
- Performance Tracker API server running

## Installation Steps

### 1. Clone the Repository
```bash
git clone https://github.com/RND036/intern.git
cd intern_app
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Configure API Endpoint
Open `lib/main.dart` and update the API base URL:

```dart
// For Android Emulator
static const String API_BASE_URL = 'http://10.0.2.2:3000/api';

// For iOS Simulator  
static const String API_BASE_URL = 'http://localhost:3000/api';

// For Physical Device (replace with your computer's IP)
static const String API_BASE_URL = 'http://192.168.1.100:3000/api';
```

### 4. Run the App
```bash
flutter run
```

## Test Credentials

**Intern Account 1:**
- Username: `john_intern`
- Password: `intern123`

**Intern Account 2:**
- Username: `jane_intern`
- Password: `intern123`

## Troubleshooting

**Connection Error:**
- Ensure API server is running
- Check if API URL is correct
- For physical device, use your computer's IP address

**Build Error:**
```bash
flutter clean
flutter pub get
flutter run
```
