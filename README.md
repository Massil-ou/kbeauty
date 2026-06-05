# kBeauty - On-Demand Beauty Services App

Une application mobile Flutter pour les services de beauté à domicile. Les clients recherchent une beauticienne, réservent un créneau, paient à l'avance, et la beauticienne confirme le rendez-vous.

## 🏗️ Architecture

### Backend (PHP)
- **Database**: Separate `kbeauty` database with 9 core tables
- **API**: RESTful endpoints following Cutoma patterns
- **Location-Based Search**: Services filterable by category and proximity
- **Real-time Availability**: Time slot management with conflict detection
- **Instant Appointments**: Auto-created upon payment confirmation

```
/Volumes/SERVER_DATA/api/src/kbeauty/
├── schema.sql                  # Database schema
├── config.php                  # Configuration
├── lib/helpers.php             # Helper functions
└── endpoints/
    ├── services/               # Service search & browse
    ├── availability/           # Time slot management
    ├── bookings/               # Booking creation
    ├── appointments/           # Appointment lifecycle
    ├── reviews/                # Client ratings
    └── stripe/                 # Payment processing
```

### Frontend (Flutter)
- **Manager Pattern**: Centralized singleton Manager with lazy-initialized sub-managers
- **Reactive State**: ChangeNotifier pattern for UI reactivity
- **Router**: GoRouter for navigation between 7 main routes
- **API Integration**: Dio HTTP client with automatic error handling

```
/Users/massil/kbeauty/lib/
├── App/
│   ├── Manager.dart                      # Central singleton
│   └── CutomaApp.dart                    # GoRouter setup
├── Dashboard/
│   ├── Services/                         # Service search & detail
│   └── Appointments/                     # Client & beautician views
├── Booking/
│   ├── BookingManager.dart               # Booking state
│   ├── AvailabilityManager.dart          # Time slots
│   ├── TimeSlotPickerView.dart           # UI: Select time
│   └── ConfirmBookingView.dart           # UI: Confirm + location
├── Appointments/
│   ├── AppointmentManager.dart           # Appointment state
│   └── MyAppointmentsView.dart           # UI: Client appointments
├── Reviews/
│   ├── ReviewManager.dart                # Review management
│   └── ReviewFormView.dart               # UI: Rate service
├── BeauticianhProfile/
│   └── BeauticianhProfileManager.dart    # Profile state
└── Shared/
    └── Models.dart                       # Data models
```

## 🚀 Quick Start

### Backend Setup
1. **Create Database**:
   ```bash
   mysql -u root -p < /Volumes/SERVER_DATA/api/src/kbeauty/schema.sql
   ```

2. **API Base URL**:
   - Configure in `.env` or `lib/App/Manager.dart`
   - Example: `https://api.kbeauty.fr`

### Flutter Setup
1. **Install Dependencies**:
   ```bash
   cd /Users/massil/kbeauty
   flutter pub get
   ```

2. **Configure Environment**:
   - Copy `.env.example` to `.env`
   - Update API_BASE_URL, Firebase credentials, Stripe keys

3. **Run App**:
   ```bash
   flutter run
   ```

## 📱 User Flows

### Client Journey
1. **Home** - Browse beauticians by service & location
2. **Service Detail** - View beautician info & reviews
3. **Time Slot Picker** - Select date & available time
4. **Confirm Booking** - Enter home address & notes
5. **Payment** - Stripe checkout (upfront)
6. **My Appointments** - Track status, write reviews

### Beautician Journey
1. **Dashboard** - See pending confirmations (red badge)
2. **Confirm/Decline** - Accept or reject appointment with reason
3. **My Appointments** - View confirmed upcoming appointments
4. **Completed** - Access client reviews & ratings

## 🔌 API Endpoints

### Services
- `POST /kbeauty/services/search` - Search with filters
- `POST /kbeauty/services/getbyid` - Service details

### Availability
- `POST /kbeauty/availability/get_slots` - Get time slots for date

### Bookings
- `POST /kbeauty/bookings/create` - Create pre-payment booking
- `POST /kbeauty/bookings/list` - Client's bookings

### Payments
- `POST /kbeauty/stripe/verify_payment` - Confirm payment, create appointment
- Auto-creates appointment on success

### Appointments
- `POST /kbeauty/appointments/confirm` - Beautician confirms
- `POST /kbeauty/appointments/decline` - Beautician declines (refund)
- `POST /kbeauty/appointments/list` - Get appointments

### Reviews
- `POST /kbeauty/reviews/add` - Submit rating (after completed)

## 📊 Database Schema Highlights

### Core Tables
- `services` - Beauty services (haircut, nails, etc.)
- `bookings` - Pre-payment bookings
- `appointments` - Confirmed appointments (created after payment)
- `beautician_availability` - Weekly working hours
- `service_reviews` - Client ratings
- `wallet_transactions` - Financial tracking
- `beautician_profiles` - Beautician details

### Key Features
- Location-based search (radius filtering)
- Time slot conflict detection (15-min buffer)
- Automatic appointment creation on payment
- Immedi Beautic Decline with instant refund
- Denormalized ratings for fast queries

## 🔐 Authentication (Reused from Cutoma)

All API endpoints use:
- `X-Device-Id` header (HMAC-signed device identifier)
- `Authorization: Bearer {accessToken}` (JWT)
- Refresh token auto-renewal (60 seconds before expiry)

## 🎨 UI Theme

**Colors**:
- Primary: `#7C3AED` (Purple)
- Secondary: `#06B6D4` (Cyan)
- Success: `#16A34A` (Green)
- Warning: `#D97706` (Orange)
- Error: `#DC2626` (Red)

**Typography**:
- Headings: Poppins Bold/SemiBold
- Body: Poppins Regular
- Font Size: 12-24px range

## 📦 Dependencies

- **Networking**: Dio (HTTP), GoRouter (navigation)
- **State**: Provider/ChangeNotifier
- **Storage**: FlutterSecureStorage (tokens), SharedPreferences (app data)
- **Payments**: stripe_flutter
- **Firebase**: firebase_core, firebase_messaging
- **Utils**: uuid, intl, flutter_dotenv

## 🔄 Data Flow

```
User Input
    ↓
View (StatefulWidget)
    ↓
Manager (ChangeNotifier)
    ↓
API Call (Dio)
    ↓
PHP Endpoint
    ↓
Database Query
    ↓
Response → Model → Manager → Widget rebuild
```

## 📝 Key Managers

| Manager | Responsibility |
|---------|-----------------|
| `ServiceManager` | Search, browse, fetch service details |
| `BookingManager` | Create bookings, track booking state |
| `AvailabilityManager` | Fetch & filter available time slots |
| `AppointmentManager` | List, confirm, decline appointments |
| `ReviewManager` | Submit & fetch reviews |
| `BeauticianhProfileManager` | Beautician profile management |

## 🧪 Testing Workflow

1. **Setup**: Create test beautician with services
2. **Client Side**:
   - Search for service
   - Pick date/time
   - Enter address
   - Process payment (Stripe test mode)
3. **Beautician Side**:
   - See pending confirmation
   - Confirm appointment
4. **Verification**:
   - Check database appointment status
   - Verify wallet transaction created
   - Test refund on decline

## 📝 Next Steps

1. **Authentication**: Integrate Cutoma's authentication system
2. **Payments**: Complete Stripe integration with test/live modes
3. **Notifications**: Push notifications for beautician bookings
4. **Maps**: Location selection & distance display
5. **Ratings**: Display beautician profile with reviews
6. **Analytics**: Track app usage & conversion metrics

## 💡 Architecture Patterns

- **Singleton**: Manager (single instance per app)
- **Factory**: Manager (lazy initialization)
- **Observer**: ChangeNotifier (reactive UI)
- **MVC**: Model/Manager/View separation
- **Dependency Injection**: Manager provides services
- **Service Locator**: Manager as central hub

---

**Created**: 2026-06-05  
**Language**: Dart/Flutter, PHP, MySQL  
**Status**: MVP Complete - Ready for Testing
