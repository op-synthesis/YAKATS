import 'package:flutter/material.dart';

class AppStrings {
  // Get current locale
  static Locale getCurrentLocale(BuildContext context) {
    return Localizations.localeOf(context);
  }

  // Check if Turkish
  static bool isTurkish(BuildContext context) {
    return getCurrentLocale(context).languageCode == 'tr';
  }

  // All app strings - English and Turkish
  static const Map<String, Map<String, String>> translations = {
    'appTitle': {'en': 'YAKATS', 'tr': 'YAKATS'},
    'welcome': {'en': 'Welcome to YAKATS', 'tr': 'YAKATS\'a Hoşgeldiniz'},
    'welcomeDescription': {
      'en':
          'Track your allergies, understand your triggers, and predict attacks with AI.',
      'tr':
          'Alerjilerinizi izleyin, tetikleyicilerinizi anlayın ve yapay zeka ile saldırıları öngörün.',
    },
    'hint': {
      'en': '🎯 Log symptoms for 2 weeks to unlock AI insights',
      'tr':
          '🎯 AI içgörülerinin kilidini açmak için 2 hafta boyunca semptomları kaydedin',
    },
    'quickActions': {'en': 'Quick Actions', 'tr': 'Hızlı İşlemler'},
    'recentActivity': {'en': 'Recent Activity', 'tr': 'Son Aktiviteler'},
    'logSymptom': {'en': 'Log Symptom', 'tr': 'Semptom Kaydet'},
    'quickEntry': {'en': 'Quick entry', 'tr': 'Hızlı giriş'},
    'history': {'en': 'History', 'tr': 'Geçmiş'},
    'viewLogs': {'en': 'View logs', 'tr': 'Günlükleri görüntüle'},
    'noSymptoms': {
      'en': 'No symptoms logged yet',
      'tr': 'Henüz semptom kaydedilmedi',
    },
    'tapButtonToLog': {
      'en': 'Tap the button below to log your first symptom',
      'tr': 'İlk semptomunuzu kaydetmek için aşağıdaki düğmeyi dokunun',
    },
    'settings': {'en': 'Settings', 'tr': 'Ayarlar'},
    'settingsComingSoon': {
      'en': 'Settings coming soon!',
      'tr': 'Ayarlar yakında geliyor!',
    },
    'goBack': {'en': 'Go Back', 'tr': 'Geri Dön'},
    'symptomLoggingForm': {
      'en': 'Symptom Logging Form',
      'tr': 'Semptom Kayıt Formu',
    },
    'comingSession2': {
      'en': 'Coming in Session 2!',
      'tr': 'Oturum 2\'de geliyor!',
    },
    'symptomHistory': {'en': 'Symptom History', 'tr': 'Semptom Geçmişi'},
    'comingSession7': {
      'en': 'Coming in Session 7!',
      'tr': 'Oturum 7\'de geliyor!',
    },
    'aiInsights': {'en': 'AI Insights', 'tr': 'Yapay Zeka İçgörüleri'},
    'aiInsightsAndAnalytics': {
      'en': 'AI Insights & Analytics',
      'tr': 'Yapay Zeka İçgörüleri ve Analitikleri',
    },
    'comingPhase2': {'en': 'Coming in Phase 2!', 'tr': 'Faz 2\'de geliyor!'},
    'error': {'en': 'Error', 'tr': 'Hata'},
    'pageNotFound': {'en': 'Page not found', 'tr': 'Sayfa bulunamadı'},
    'goHome': {'en': 'Go Home', 'tr': 'Anasayfaya Git'},
    // NEW STRINGS FOR SESSION 2
    'symptomType': {'en': 'Symptom Type', 'tr': 'Semptom Türü'},
    'selectSymptomType': {
      'en': 'Select symptom type',
      'tr': 'Semptom türünü seçin',
    },
    'runnyNose': {'en': 'Runny Nose', 'tr': 'Akan Burun'},
    'sneezing': {'en': 'Sneezing', 'tr': 'Hapşırma'},
    'itchyEyes': {'en': 'Itchy Eyes', 'tr': 'Kaşıntılı Gözler'},
    'cough': {'en': 'Cough', 'tr': 'Öksürük'},
    'shortnessOfBreath': {'en': 'Shortness of Breath', 'tr': 'Nefes Darlığı'},
    'skinRash': {'en': 'Skin Rash', 'tr': 'Cilt Dönerme'},
    'swelling': {'en': 'Swelling', 'tr': 'Şişme'},
    'other': {'en': 'Other', 'tr': 'Diğer'},
    'severity': {'en': 'Severity', 'tr': 'Şiddet'},
    'mild': {'en': 'Mild', 'tr': 'Hafif'},
    'moderate': {'en': 'Moderate', 'tr': 'Orta'},
    'severe': {'en': 'Severe', 'tr': 'Şiddetli'},
    'notes': {'en': 'Notes', 'tr': 'Notlar'},
    'addOptionalNotes': {
      'en': 'Add optional notes about your symptoms',
      'tr': 'Semptomlarınız hakkında isteğe bağlı notlar ekleyin',
    },
    'time': {'en': 'Time', 'tr': 'Saat'},
    'save': {'en': 'Save', 'tr': 'Kaydet'},
    'cancel': {'en': 'Cancel', 'tr': 'İptal Et'},
    'symptomSaved': {
      'en': 'Symptom saved successfully!',
      'tr': 'Semptom başarıyla kaydedildi!',
    },
    'errorSavingSymptom': {
      'en': 'Error saving symptom',
      'tr': 'Semptom kaydedilirken hata oluştu',
    },
    'pleaseSelectSymptom': {
      'en': 'Please select a symptom type',
      'tr': 'Lütfen bir semptom türü seçin',
    },
    'noSymptomsLogged': {
      'en': 'No symptoms logged yet',
      'tr': 'Henüz semptom kaydedilmedi',
    },
    'today': {'en': 'Today', 'tr': 'Bugün'},
    'yesterday': {'en': 'Yesterday', 'tr': 'Dün'},
    'thisWeek': {'en': 'This Week', 'tr': 'Bu Hafta'},
    'thisMonth': {'en': 'This Month', 'tr': 'Bu Ay'},
    'all': {'en': 'All', 'tr': 'Tümü'},
    'totalSymptoms': {'en': 'Total Symptoms', 'tr': 'Toplam Semptom'},
    'avgSeverity': {'en': 'Avg. Severity', 'tr': 'Ort. Şiddet'},
    'delete': {'en': 'Delete', 'tr': 'Sil'},
    'deleteConfirm': {
      'en': 'Are you sure you want to delete this symptom?',
      'tr': 'Bu semptomu silmek istediğinizden emin misiniz?',
    },
    'symptomDeleted': {'en': 'Symptom deleted', 'tr': 'Semptom silindi'},
    'temperature': {'en': 'Temperature', 'tr': 'Sıcaklık'},
    'humidity': {'en': 'Humidity', 'tr': 'Nem'},
    'weather': {'en': 'Weather', 'tr': 'Hava Durumu'},
    'location': {'en': 'Location', 'tr': 'Konum'},
    'symptomDetails': {'en': 'Symptom Details', 'tr': 'Semptom Detayları'},

    'aıInsıghts': {'en': 'AI Insights', 'tr': 'Yapay Zeka İçgörüleri'},
    'triggers': {'en': 'Your Triggers', 'tr': 'Tetikleyicileriniz'},
    'statistics': {'en': 'Statistics', 'tr': 'İstatistikler'},
    'confidence': {'en': 'Confidence', 'tr': 'Güven'},
    'notEnoughData': {
      'en': 'Not enough data to analyze',
      'tr': 'Analiz için yeterli veri yok',
    },
    'logMoreSymptoms': {
      'en': 'Log at least 10 symptoms to see AI insights',
      'tr': 'Yapay Zeka içgörülerini görmek için en az 10 semptom kaydedin',
    },
    'noTriggerFound': {
      'en': 'No clear triggers found yet',
      'tr': 'Henüz belirgin tetikleyici bulunamadı',
    },
    'keepLogging': {
      'en': 'Keep logging symptoms to discover patterns',
      'tr': 'Desenleri keşfetmek için semptom kaydetmeye devam edin',
    },
    'triggerType': {'en': 'Type', 'tr': 'Tür'},
    'evidence': {'en': 'Evidence', 'tr': 'Kanıtlar'},
    'severityTrend': {'en': 'Severity Trend', 'tr': 'Şiddet Trendi'},
    'mostCommonSymptom': {
      'en': 'Most Common Symptom',
      'tr': 'En Yaygın Semptom',
    },
    'avgSeverityLabel': {'en': 'Average Severity', 'tr': 'Ortalama Şiddet'},
    'totalLogged': {'en': 'Total Logged', 'tr': 'Toplam Kaydedilen'},
  };

  // Get string by key and language
  static String get(String key, {String language = 'tr'}) {
    return translations[key]?[language] ?? key;
  }

  // Turkish getter (default to Turkish)
  static String tr(String key) {
    return translations[key]?['tr'] ?? key;
  }

  // English getter
  static String en(String key) {
    return translations[key]?['en'] ?? key;
  }
}
