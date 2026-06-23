# MD & V Laundry Shop — Mobile App

Flutter mobile client for the **MD & V Laundry Shop** IT9 system. Connects to the same Laravel REST API as the web client and keeps order data in sync across platforms.

## Setup

1. Start the Laravel API from the `server/` folder:
   ```bash
   php artisan serve
   ```
2. Install Flutter dependencies:
   ```bash
   cd mobile
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

### API URL configuration

Edit `lib/config/api_config.dart` if needed:

| Environment | URL |
|-------------|-----|
| Windows / Web / iOS simulator | `http://127.0.0.1:8000/api` |
| Android emulator | `http://10.0.2.2:8000/api` (auto-detected) |
| Physical device on Wi‑Fi | Set `lanHost` to your PC's LAN IP |

## IT9 Required Features

### Authentication
- **Login** — `POST /api/auth/login` with email and password
- **Register** — `POST /api/auth/register` for new customer accounts
- **API-based auth** — Laravel Sanctum bearer tokens
- **Session handling** — Token and user profile stored in `SharedPreferences`; restored on app launch via `GET /api/auth/me`
- **Logout** — `POST /api/auth/logout` with confirmation dialog

### Mobile Features (data from IT9 database)
- **My Orders** — List bookings from `GET /api/my-orders`
- **Order details** — View full booking from `GET /api/bookings/{id}`
- **Track order** — Look up status via `POST /api/bookings/track`
- **Services & pricing** — Load catalog from `GET /api/services`

### Core actions (CRUD)
| Action | Screen | API |
|--------|--------|-----|
| **Add** record | Create Order | `POST /api/bookings` |
| **Update** record | Edit Order | `PUT /api/bookings/{id}` |
| **Cancel** request | Order Detail | `POST /api/bookings/{id}/cancel` |
| **Delete** record | Order Detail | `POST /api/bookings/{id}/trash` + `DELETE /api/bookings/{id}/force` |

### API integration
- RESTful Laravel backend (`server/routes/api.php`)
- HTTP methods: **GET**, **POST**, **PUT**, **DELETE**
- JSON request/response with `Authorization: Bearer {token}`
- Shared data model with the React web client (same endpoints, same database)

### UI/UX
- Navy + sky branding aligned with the web system
- Bottom navigation: Orders, Track, Services, Account
- Organized forms with validation on login, register, and booking screens
- Pull-to-refresh on orders and services lists
- Status chips with colors matching the web app

## Project structure

```
lib/
├── config/api_config.dart    # Backend URL
├── models/                   # User, Booking, Service, Payment
├── screens/                  # UI screens
├── services/
│   ├── api_service.dart      # REST API client
│   └── auth_storage.dart     # Session persistence
├── theme/app_theme.dart      # Brand theme
├── utils/constants.dart      # Business rules & colors
└── widgets/brand_logo.dart   # Shared branding
```
