# Collex 🎒 — Campus Exchange Platform

**A simple, minimal Flutter + Supabase app where students can buy, sell, and exchange items within their college.**

---

## 🚀 Quick Start

### 1. Prerequisites

- Flutter SDK ≥ 3.7.0
- Dart SDK ≥ 3.7.0
- A [Supabase](https://supabase.com) account (free tier works)
- Android Studio or VS Code

---

### 2. Supabase Setup

1. Go to [supabase.com](https://supabase.com) and create a new project
2. Open the **SQL Editor** and run the entire contents of `supabase_schema.sql`
3. Go to **Storage → Create Bucket** and name it `item-images` (set to **Public**)
4. Copy your **Project URL** and **anon public key** from Project Settings → API

---

### 3. Configure App

Open `lib/core/constants/app_constants.dart` and update:

```dart
static const String supabaseUrl = 'YOUR_SUPABASE_PROJECT_URL';
static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
static const String collegeDomain = '@yourcollege.edu'; // Optional domain restriction
```

---

### 4. Run the App

```bash
flutter pub get
flutter run
```

---

## 📁 Project Structure

```
lib/
├── core/
│   ├── constants/        # App-wide constants
│   └── theme/            # Light + Dark theme
├── data/
│   ├── models/           # Data models (User, Item, Request, Message)
│   ├── providers/        # State management (Auth, Item, Request)
│   └── services/         # Supabase API calls
└── presentation/
    ├── router/           # GoRouter configuration
    ├── screens/
    │   ├── auth/         # Login, Signup
    │   ├── home/         # Home feed
    │   ├── item/         # Add item, Item detail, Requests
    │   ├── chat/         # Conversation list, Chat screen
    │   └── profile/      # Profile + my listings
    └── widgets/
        ├── common/       # AppTextField, AppButton, MainShell
        └── item/         # ItemCard, ItemCardSkeleton
```

---

## 🧩 Features

| Feature | Status |
|---|---|
| Email/Password Authentication | ✅ |
| Browse Items (Search + Filter) | ✅ |
| Post Item (with image upload) | ✅ |
| Item Detail View | ✅ |
| Request System (Accept/Reject) | ✅ |
| Real-time Chat | ✅ |
| Profile + My Listings | ✅ |
| Mark Item as Sold | ✅ |
| Free Items Toggle | ✅ |
| Dark Mode | ✅ |
| Shimmer Loading Skeletons | ✅ |

---

## 🎨 Design

- **Theme:** Material 3
- **Colors:** Deep Blue (#2563EB) + Soft Purple (#7C3AED)
- **Font:** Poppins (via Google Fonts)
- **Dark background:** #0F172A
- **Card (dark):** #1E293B

---

## 🗄️ Database Schema

### users
| Column | Type | Notes |
|---|---|---|
| id | UUID | FK → auth.users |
| name | TEXT | |
| email | TEXT | |
| role | TEXT | Default: student |
| rating | DECIMAL | Default: 0.0 |
| avatar_url | TEXT | |

### items
| Column | Type | Notes |
|---|---|---|
| id | UUID | PK |
| title | TEXT | |
| description | TEXT | |
| price | DECIMAL | 0 = Free |
| category | TEXT | |
| condition | TEXT | New/Good/Used |
| image_url | TEXT | Supabase Storage |
| seller_id | UUID | FK → users |
| is_sold | BOOLEAN | |

### requests
| Column | Type | Notes |
|---|---|---|
| id | UUID | PK |
| item_id | UUID | FK → items |
| requester_id | UUID | FK → users |
| status | TEXT | pending/accepted/rejected |

### messages
| Column | Type | Notes |
|---|---|---|
| id | UUID | PK |
| sender_id | UUID | FK → users |
| receiver_id | UUID | FK → users |
| message | TEXT | |
| created_at | TIMESTAMPTZ | |

---

## 📦 Dependencies

| Package | Purpose |
|---|---|
| `supabase_flutter` | Backend (Auth, DB, Storage, Realtime) |
| `provider` | State management |
| `go_router` | Navigation |
| `google_fonts` | Poppins font |
| `cached_network_image` | Efficient image loading |
| `shimmer` | Skeleton loading placeholders |
| `image_picker` | Pick images from gallery |
| `timeago` | Human-readable timestamps |
| `uuid` | Unique file names for uploads |

---

## 🔐 Row Level Security

All tables use **RLS policies** to ensure:
- Users can only **edit their own data**
- Messages are only visible to **sender and receiver**
- Requests are only visible to **seller and requester**
- Items are **publicly viewable**

---

## 📱 Screenshots

The app includes:
- **Home Feed** — Grid of items with search + category filters
- **Add Item** — Minimal form with image picker and condition selector
- **Item Detail** — Full details with request + chat buttons
- **Chat** — WhatsApp-style real-time messaging
- **Profile** — Listings and request history with tabs

---

## 🛠️ Customization

- Change college domain restriction in `app_constants.dart`
- Add more categories in `AppConstants.categories`
- Swap Poppins for another font in `app_theme.dart`
- The theme supports both light and dark mode out of the box

---

*Built with Flutter + Supabase. Designed for campus life.* 🎓
