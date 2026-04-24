# YAKATS — Current State Summary


---

### The Core Promise
> *"Track your allergy and respiratory symptoms, understand your triggers, and contribute anonymously to medical research."*

---

## What the App Has Right Now

### Foundation & Infrastructure
```
✅ Flutter project — fully structured and running
✅ GoRouter navigation — all screens connected
✅ Provider state management — theme + settings
✅ SharedPreferences — persistent user preferences
✅ SQLite local database (sqflite) — all data stored locally
✅ No Firebase — fully independent backend choice
✅ App icon — generated and configured
✅ Splash screen — branded, animated
```

---

### Symptom Logging System
```
✅ Full symptom logging form
✅ Symptom types (allergic, respiratory, skin, eye, etc.)
✅ Severity scale input
✅ Automatic timestamp on every log
✅ GPS location captured at log time
✅ Weather data captured at log time:
     — temperature
     — humidity
     — wind speed
     — weather condition
✅ All data saved to local SQLite database
```

---

### History & Data Review
```
✅ History screen — all past logs listed
✅ Filtering — by symptom type, date range
✅ Symptom detail view — full context per entry
✅ Delete functionality — remove individual logs
✅ Home screen — shows recent activity summary
```

---

### AI / Analytics Engine
```
✅ Analytics engine — processes local symptom history
✅ Insights screen — visualizes patterns
✅ Risk prediction service — calculates risk level
✅ Risk details screen — explains the risk score
✅ Alert system — notifies user of elevated risk
✅ Alert history screen — past alerts stored and viewable
✅ Background service — monitors conditions passively
```

---

### Notifications
```
✅ Awesome Notifications integration
✅ Risk-based push alerts
✅ Alert logging to local database
```

---

### Settings & Personalization
```
✅ Settings screen — full preferences UI
✅ Light / Dark theme toggle — persisted
✅ Alert configuration options
✅ Risk threshold settings
✅ Monitoring preferences
✅ About section with app branding
```

---

### Design & UI
```
✅ Premium wellness app aesthetic
✅ Bento-inspired home screen layout
✅ Branded splash screen:
     — Black background
     — YAKATS wordmark (Syncopate font)
     — Dark-blue animated arc
✅ YAKATS logo widget — reusable
✅ Consistent design language across screens
✅ Light and dark theme fully styled
```

---

### Services Layer
```
✅ LocationService    — GPS coordinates
✅ WeatherService     — live weather data
✅ DatabaseService    — all local CRUD operations
✅ AnalyticsService   — pattern recognition
✅ RiskPredictionService — risk scoring
✅ AlertService       — alert logic
✅ NotificationsService  — push delivery
✅ BackgroundService  — passive monitoring
```

---

## What Is NOT Built Yet
```
⬜ Supabase integration
⬜ Anonymous research data upload
⬜ User consent / KVKK consent screen
⬜ Privacy policy screen
⬜ Research info screen
⬜ Anonymization service
⬜ Daily upload scheduler
⬜ Research participation toggle in settings
```

---

## By the Numbers

```
Screens   :  8 existing  (+3 to be added)
Services  :  9 existing  (+3 to be added)
Models    :  4 existing  (+fields to be added)
Widgets   :  2+ existing
Database  :  local SQLite, fully working
Backend   :  none yet — Supabase coming next
```

---

## In Summary

```

YAKATS is currently a fully working AI-powered personal allergy and respiratory symptom tracking application built with Flutter.

The app allows users to log symptoms along with severity, and it automatically captures contextual data such as GPS location and
weather conditions (temperature, humidity, wind speed, weather type). All data is stored locally using SQLite. Users can view
their symptom history, filter it, see detailed entries, and delete logs if needed.

An internal analytics engine processes the collected data to identify patterns and generate risk predictions. Based on these
 predictions, the app can trigger alerts and notifications. Alert history is also stored locally. Background monitoring
 and risk evaluation are already implemented.

The app has a premium UI with light and dark themes, a branded splash screen with an animated arc design, and a structured
navigation system using GoRouter. Settings include theme switching, alert preferences, and monitoring controls, all
persisted with SharedPreferences.

There is currently no backend. All data stays on the device. Supabase integration for anonymized research data uploads has
 not yet been implemented.

In short, YAKATS is already a complete local AI health-tracking app with analytics, alerts, and a polished design.
 The next step is to extend it into a privacy-safe, anonymous medical research contribution platform.

```

---

## Note on Development

```

This project was architected and built in a 72-hour sprint by a 17-year-old student (high school senior) as a
demonstration of rapid prototyping, AI-assisted development, and system architecture.


