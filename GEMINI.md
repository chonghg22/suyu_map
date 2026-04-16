# Mammazone (맘마존) - Project Overview

Mammazone is a Flutter-based mobile application designed to provide a nationwide nursing room map. It helps parents find and navigate to nursing rooms across South Korea, providing details, reviews, and favorites.

## Core Technologies
- **Framework:** [Flutter](https://flutter.dev/) (v3.11.1 SDK or higher)
- **Backend/DB:** [Supabase](https://supabase.com/) (using `supabase_flutter`)
- **Map SDK:** [Naver Map SDK](https://github.com/note11g/flutter_naver_map) (`flutter_naver_map`)
- **State Management:** [Riverpod](https://riverpod.dev/) (`flutter_riverpod`, `riverpod_generator`)
- **Routing:** [Go Router](https://pub.dev/packages/go_router)
- **Location & Permissions:** `geolocator`, `permission_handler`
- **Other Utils:** `cached_network_image`, `intl`, `url_launcher`, `flutter_dotenv`

## Project Architecture
The project follows a feature-driven directory structure:

- **`lib/core/`**: Centralized configurations, constants, router, themes, and global services (e.g., `device_id_service`).
- **`lib/data/`**: Data layer containing:
  - `models/`: Data classes (e.g., `NursingRoom`, `Favorite`, `Review`).
  - `repositories/`: Abstract and concrete implementations for data fetching and persistence.
- **`lib/features/`**: Feature-specific UI and business logic:
  - `map/`: Naver Map integration and room discovery.
  - `detail/`: Room details, amenities, and reviews.
  - `favorite/`: User-saved nursing rooms.
  - `mypage/`: User profile and settings.
  - `report/`: Reporting new rooms or correcting information.
  - `search/`: Search functionality.
- **`lib/shared/`**: Common widgets and UI components used across multiple features (e.g., `MainShell`).

## Building and Running

### Prerequisites
- Flutter SDK installed and configured.
- Android Studio / VS Code with Flutter extensions.
- Valid Supabase and Naver Map API keys (configured in `main.dart` or `.env`).

### Commands
- **Install dependencies:**
  ```bash
  flutter pub get
  ```
- **Run the app:**
  ```bash
  flutter run
  ```
- **Build the app (Android):**
  ```bash
  flutter build apk
  ```
- **Build the app (iOS):**
  ```bash
  flutter build ios
  ```
- **Generate Riverpod/JSON code:**
  ```bash
  flutter pub run build_runner build --delete-conflicting-outputs
  ```

## Development Conventions

### State Management
- Use **Riverpod** for all state management.
- Prefer using `@riverpod` annotations and `build_runner` for generating providers.
- Keep business logic in providers/notifiers and UI in `ConsumerWidget` or `ConsumerStatefulWidget`.

### Routing
- Navigation is handled by **Go Router** defined in `lib/core/router/app_router.dart`.
- Use `context.go()` or `context.push()` with named routes where possible.

### UI & Styling
- Follow the theme defined in `lib/core/theme/app_theme.dart`.
- Shared components should be placed in `lib/shared/widgets/`.

### Supabase Integration
- Supabase is initialized in `main.dart`.
- Constants related to Supabase tables and storage are in `lib/core/constants/supabase_constants.dart`.

## TODO / Future Enhancements
- [ ] Implement full review system.
- [ ] Implement user authentication if needed beyond device ID.
- [ ] Add unit and widget tests in the `test/` directory.
