# MD & V Laundry Shop

Full-stack laundry service management website with customer booking and admin dashboard.

## Tech Stack

| Layer | Stack |
|-------|-------|
| Frontend | React 19, Vite, Tailwind CSS 4, Axios, React Router, Framer Motion, Lucide React, Recharts |
| Backend | Laravel 12, Sanctum, MySQL/SQLite |
| Database | MySQL (production) / SQLite (local dev) |

## Project Structure

```
├── client/          # React + Vite frontend
├── server/          # Laravel 12 API
└── docs/            # Project documentation
```

## Automation (n8n + Telegram)

This project includes a **working n8n automation integration** for the Final Project / Final Examination requirement (IT 9 + CC6).

When a customer creates a booking or an admin updates order status, Laravel sends a webhook to n8n, which automatically sends a **Telegram** notification to the shop admin.

**Full step-by-step guide:** [docs/n8n-telegram-automation.md](docs/n8n-telegram-automation.md)

Quick enable in `server/.env`:

```env
N8N_ENABLED=true
N8N_WEBHOOK_URL=http://localhost:5678/webhook/mdv-laundry
N8N_WEBHOOK_SECRET=mdv-secret-2026
```

## Prerequisites

- Node.js 18+
- PHP 8.2+
- Composer
- MySQL (optional — SQLite works for local dev)

## Setup

### 1. Backend (Laravel API)

```bash
cd server
composer install
cp .env.example .env
php artisan key:generate
```

**MySQL** — update `.env`:
```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=mdv_laundry
DB_USERNAME=root
DB_PASSWORD=
```

**SQLite** (default) — already configured in `.env.example`.

```bash
php artisan migrate:fresh --seed
php artisan serve
```

API runs at: `http://127.0.0.1:8000`

### 2. Frontend (React)

```bash
cd client
npm install
cp .env.example .env
npm run dev
```

Frontend runs at: `http://localhost:5173`

## Default Accounts

| Role | Email | Password |
|------|-------|----------|
| Admin | admin@mdvlaundry.com | password123 |
| Customer | customer@example.com | password123 |

## API Endpoints

### Public
- `POST /api/auth/register` — Register customer
- `POST /api/auth/login` — Login
- `GET /api/services` — List services
- `GET /api/testimonials` — List testimonials
- `POST /api/bookings` — Create booking
- `POST /api/bookings/track` — Track by code

### Authenticated
- `GET /api/auth/me` — Current user
- `POST /api/auth/logout` — Logout
- `GET /api/my-orders` — Customer orders

### Admin (requires admin role)
- `GET /api/admin/dashboard` — Analytics
- `GET /api/admin/bookings` — Orders list
- `PATCH /api/admin/bookings/{id}/status` — Update status
- `GET /api/admin/customers` — Customers
- `GET /api/admin/payments` — Payments
- `PATCH /api/admin/payments/{id}` — Update payment
- `GET /api/admin/services` — Manage services
- `GET /api/admin/reports` — Reports

## Booking Management System

### Status Flow
`Pending` → `Confirmed` → `Pickup Scheduled` → `Washing` → `Drying` → `Folding` → `Out for Delivery` → `Finished` (or `Cancelled`)

### Customer
- Create / edit / cancel bookings (before processing)
- Live tracking with auto-refresh (20s) + QR code
- Notification bell with unread counter
- Customer dashboard at `/dashboard`
- Notifications page at `/notifications`

### Admin
- Full booking table with search & filters
- Update status + assign delivery rider
- Mark **Done** / **Not Done**
- Delete bookings
- Export booking PDF
- Auto-notify customers on every status change

### Notifications
- Database notifications (in-app bell + dropdown)
- Email via Laravel Mail
- **SMS** via Semaphore API (or dev log mode) with `sms_logs` table
- Customer SMS history on dashboard
- Laravel Events + Broadcasting ready (Pusher optional)

### New API Endpoints
| Method | Endpoint | Description |
|--------|----------|-------------|
| PUT | `/api/bookings/{id}` | Edit booking |
| POST | `/api/bookings/{id}/cancel` | Cancel booking |
| GET | `/api/notifications` | List notifications |
| PATCH | `/api/notifications/{id}/read` | Mark read |
| PATCH | `/api/admin/bookings/{id}/done` | Mark done |
| PATCH | `/api/admin/bookings/{id}/not-done` | Mark not done |
| DELETE | `/api/admin/bookings/{id}` | Delete booking |

### Optional: Real-time (Pusher)
```env
BROADCAST_CONNECTION=pusher
PUSHER_APP_ID=your-id
PUSHER_APP_KEY=your-key
PUSHER_APP_SECRET=your-secret
VITE_PUSHER_APP_KEY=your-key
```
Without Pusher, notifications poll every 15 seconds automatically.

## Features

### Customer Website
- Home, Services, Pricing, Booking, Tracker, About, Contact, Dashboard
- Online booking with GPS location + Google Maps (optional API key)
- Real-time order tracking timeline with estimated completion
- SMS contact buttons (no Messenger)
- Mobile bottom navigation + logout confirmation modal
- Login / Register
- Dark mode, floating Call & SMS buttons
- Edit/cancel bookings only before laundry is finished

### Admin Dashboard
- Analytics widgets & charts
- Order management with status updates + **Finish / Cancel** actions (auto-SMS)
- Customer list with search
- Payment tracking
- Service/pricing management
- Reports with revenue & status breakdown

### SMS Configuration (server `.env`)
```env
SMS_ENABLED=true
SMS_API_KEY=your_semaphore_api_key
SMS_PROVIDER=semaphore
SMS_SENDER_NAME=MDVLaundry
```

### Google Maps (client `.env`)
```env
VITE_GOOGLE_MAPS_API_KEY=your_google_maps_api_key
```

## Production Build

```bash
# Frontend
cd client && npm run build

# Backend
cd server && php artisan config:cache && php artisan route:cache
```

Serve `client/dist` via your web server and point API requests to the Laravel backend.

## Contact

**MD & V Laundry Shop**  
Phone: 0969 150 3988  
Hours: Monday–Sunday, 8AM–7PM
