# Cached Jokes App

A Flutter mobile application that brings humor to your fingertips! The app fetches jokes from JokeAPI and caches them locally, ensuring you're always entertained, whether you're online or offline. With a clean interface and robust features, the app offers a delightful user experience.

---

## 🚀 Key Features

- **Fetch Jokes Online**: Retrieves 5 random jokes using JokeAPI.
- **Offline Mode**: Access your jokes anytime, even without an internet connection.
- **Smart Caching**: Saves jokes locally using `shared_preferences` for seamless access.
- **Automatic Updates**: Refreshes the joke cache when online.
- **Network Detection**: Automatically detects online/offline status.
- **Error-Resilient**: Handles errors gracefully, keeping the app smooth and functional.

---

## 🛠️ Technical Details

### Prerequisites
- **Flutter SDK**: Version 3.24.3 or later
- **Dart SDK**: Version 3.5.3 or later
- IDE: Android Studio or VS Code with Flutter extensions
- Device: Physical device or emulator for testing

### Dependencies
Add these to your `pubspec.yaml` file:
```yaml
dependencies:
  flutter:
    sdk: flutter
  shared_preferences: ^2.2.0
  dio: ^5.3.2
 
```

---

## 📦 Installation Guide

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/SILVA-HSL/Joke_app.git
   ```

2. **Navigate to the Project Directory**:
   ```bash
   cd Joke_app
   ```

3. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

4. **Run the Application**:
   ```bash
   flutter run
   ```

---

## 🏗️ Application Architecture

The app is built using a clean architecture pattern with three layers:

1. **Data Layer**: Handles API calls and local caching with `shared_preferences`.
2. **Domain Layer**: Processes business logic and defines core data models.
3. **Presentation Layer**: Displays the user interface and manages app state.

---

## ⚙️ Core Functionalities

### **Joke Caching**
Code to save and retrieve jokes:
```dart
Future<void> cacheJokes(List<Joke> jokes) async {
    final jokesJson = jokes.map((joke) => joke.toJson()).toList();
    await _prefs.setString(_cacheKey, jsonEncode(jokesJson));
  }

  Future<List<Joke>> getCachedJokes() async {
    final jsonString = _prefs.getString(_cacheKey);
    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Joke.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
```

### **API Integration**
Code to fetch jokes from the API:
```dart
 final response = await _dio.get(
        "https://v2.jokeapi.dev/joke/Programming,Christmas?blacklistFlags=nsfw,religious,racist&amount=5",
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jokesJson = response.data['jokes'];
        final jokes = jokesJson.map((json) => Joke.fromJson(json)).toList();
        await cacheJokes(jokes);
        await _prefs.setInt(
            _lastFetchKey, DateTime.now().millisecondsSinceEpoch);
        return jokes;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
```

---

## 📸 Screenshots

| Online Mode                     | Cached Jokes                     | Cached Jokes                   |
|---------------------------------|----------------------------------|--------------------------------|
| ![Screenshot 1](images/2.png)  | ![Screenshot 2](images/1.png)   | ![Screenshot 3](images/1.png) |

---

Enjoy a world of humor wherever you are! 😊
