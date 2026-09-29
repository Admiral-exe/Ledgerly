# Ledgerly 💸
### Modern FinTech Personal Finance & Expense Tracker

[![Flutter](https://img.shields.io/badge/Flutter-3.44.6-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.12.2-0175C2?logo=dart)](https://dart.dev)
[![State Management](https://img.shields.io/badge/State-Riverpod-blue)](https://riverpod.dev)
[![Motion](https://img.shields.io/badge/Animations-flutter__animate-green)](https://pub.dev/packages/flutter_animate)
[![Storage](https://img.shields.io/badge/Storage-Hive-orange)](https://pub.dev/packages/hive)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Ledgerly** is a high-grade mobile application built using Flutter. Designed with Apple Card & Revolut style minimalism, it combines dark navy contrast with neon mint-green accents, pill-geometry components, and 60/120 FPS physics-based fluid transitions.

Repository: [https://github.com/Admiral-exe/Ledgerly.git](https://github.com/Admiral-exe/Ledgerly.git)

---

## ✨ Features

- ⚡ **4-Stage Choreographed Splash Sequence**: Recreated from `Flash Screen 1–3 & End` with spring scaling, ambient glowing radial aura, expanding accent rule, and brand typography reveal.
- 📱 **Welcome & Onboarding**: 3D financial growth chart illustration with neon-green trajectory, value proposition, and quick access.
- 🔐 **Authentication Flow**:
  - **Login Screen**: Mobile number input with "Send OTP" action and interactive 6-digit OTP verification modal.
  - **Sign-Up Screen**: First name, last name, email, and phone validation with smooth login cross-link.
- 📊 **Home Financial Dashboard**:
  - Real-time rolling balance and monthly spending counter (`AnimatedCurrencyCounter`).
  - Budget progress bar and remaining budget tracker.
  - Quick-glance Top Categories horizontal cards (Food & Dining, Transport) with direct deep-linking.
  - Recent transactions list with type-colored icons and relative time stamps.
- 🎯 **Budget Hub & Allocation**:
  - Month switcher (`< April 2026 >`).
  - Dark summary card with spent/remaining counters and custom-painted glowing **Radial Progress Gauge** (`65% USED`).
  - Category budget tracking bars with utilization percentages.
  - **Edit Budget Screen**: Dynamic category allocation sliders, auto-apply AI recommendations (`₹55,000 Auto-Apply`), and budget reconciliation meter.
  - **Budget Success Celebration**: Ambient green celebration checkmark with calculated daily spending limit card (`₹1,666 / day`).
- 🍽️ **Category Deep-Dive (Dining / Travel)**:
  - Monthly spending vs budget progress bar.
  - High-level metrics: *Avg. per day (₹415)* and *Frequent Day (Friday)*.
  - Full categorized activity timeline.
- 💳 **3-Way Transaction Modal**:
  - Smooth morphing segmented pill selector (**Income | Expense | Transfer**).
  - Centered large hero amount input.
  - Interactive **Import Excel** button for statement ingestion.
  - Date picker, payment mode / account selector, and notes.
  - Responsive Category Grid with haptic selection feedback.
- 🤖 **Ledgerly AI Financial Assistant**:
  - Conversational chat interface with financial intelligence.
  - Visual trend badges (*"15% lower than weekly average"*).
  - Horizontally scrollable quick prompt chips (*"Summarize my month"*, *"Am I over budget?"*).
- 📈 **Analytics Hub**:
  - Custom multi-segment interactive **Donut Chart** with legend breakdown.
  - **Export Balance Sheet** to PDF/CSV.
  - Category share meters and dark **Smart Insight** callouts.
- 🔔 **Notification Center**:
  - Grouped updates (Today / Yesterday) with "Mark all as read".
  - Savings milestone awards and food budget alert cards.
  - Promotional **Ledgerly Premium** banner with 3D rocket graphic.
- 👤 **Profile & Settings**:
  - User avatar and account details (Rahul Sharma, `sharahul@ledgerly.in`).
  - Account, Notifications, Security & Biometrics, and 24/7 Help tiles.
  - Outlined logout action with state reset and confirmation dialog.

---

## 🎨 UI Frame References

The app implements all 19 Figma frames located in [`UI frames/`](UI%20frames/):
- `AI Chat Frame.png`
- `Analytics Frame.png`
- `Budget Frame.png`
- `Budget Main Frame.png`
- `Budget updated Frame.png`
- `Dining Frame.png`
- `Flash Screen part-1.png`, `part-2.png`, `part-3.png`, `Flash Screen end.png`
- `Home Dashboard Frame.png`
- `Login Frame.png`
- `Notification Frame.png`
- `Profile Frame.png`
- `Sign-Up Frame.png`
- `Transaction- Expence Frame.png`, `Income Frame.png`, `Transfer Frame.png`
- `Welcome Frame.png`

---

## 🛠️ Tech Stack & Architecture

- **Framework**: [Flutter 3.44+](https://flutter.dev) (Dart 3.12+)
- **State Management**: [Riverpod](https://riverpod.dev) (`flutter_riverpod`)
- **Animations & Motion**: [flutter_animate](https://pub.dev/packages/flutter_animate) + custom `AnimationController` + `CustomPainter`
- **Local Storage**: [Hive](https://pub.dev/packages/hive) + `hive_flutter`
- **Typography & Icons**: [Google Fonts (Plus Jakarta Sans)](https://fonts.google.com/specimen/Plus+Jakarta+Sans) + Material 3 Icons
- **Formatting**: [intl](https://pub.dev/packages/intl) for Indian Rupee (`₹`) and localized dates

---

## 📁 Directory Structure

```
lib/
├── core/
│   ├── theme/
│   │   ├── app_colors.dart          # Semantic palettes & brand tones
│   │   ├── app_typography.dart      # Plus Jakarta Sans text styles
│   │   └── app_theme.dart           # Light Material3 theme
│   ├── widgets/
│   │   ├── animated_currency_counter.dart # Rolling number rollup
│   │   ├── bouncing_button.dart     # Tactile micro-scale button with haptics
│   │   ├── ledgerly_logo.dart       # Vector book + rupee + checkmark logo
│   │   └── smooth_page_route.dart   # FadeThrough and slide transitions
│   └── utils/
│       └── formatters.dart          # Currency (₹) and date formatters
├── data/
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── transaction_model.dart
│   │   └── budget_model.dart
│   └── mock_data.dart               # Seeded Figma mock data
├── state/
│   ├── auth_state.dart              # Authentication notifier & provider
│   ├── budget_state.dart            # Monthly & category budgets
│   └── transaction_state.dart       # Transactions stream & computed spending
├── features/
│   ├── splash/                      # 4-stage animated flash screen
│   ├── welcome/                     # 3D chart graphic & Get Started CTA
│   ├── auth/                        # Login & Sign-Up flows
│   ├── home/                        # Home financial dashboard
│   ├── budget/                      # Budget Hub, Edit Budget, Success screen, Category Detail
│   ├── transactions/                # Income / Expense / Transfer modal
│   ├── ai_chat/                     # Ledgerly AI conversational assistant
│   ├── analytics/                   # Donut chart & monthly breakdown
│   ├── notifications/               # Notification center & premium promo
│   ├── profile/                     # Profile & settings
│   └── main_scaffold.dart           # Floating pill nav bar + docked green FAB + AI sparkle
└── main.dart                        # App entry point with Hive & ProviderScope
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.24.0 or higher recommended)
- Android Studio / VS Code / Google Chrome / Windows Desktop build tools

### Installation & Run

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Admiral-exe/Ledgerly.git
   cd Ledgerly
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run unit & widget tests:**
   ```bash
   flutter test
   ```

4. **Launch the application:**
   ```bash
   # On Google Chrome (Web)
   flutter run -d chrome

   # On Windows Desktop
   flutter run -d windows

   # On an Android device or emulator
   flutter run
   ```

---

## 📄 License
This project is open-source and licensed under the [MIT License](LICENSE).
