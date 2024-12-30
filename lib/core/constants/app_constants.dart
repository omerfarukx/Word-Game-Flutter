class AppConstants {
  // Uygulama Genel Sabitleri
  static const String appName = 'Hızlı Okuma';
  static const String appVersion = '1.0.0';

  // Abonelik Tipleri
  static const String freePlan = 'free';
  static const String premiumPlan = 'premium';
  static const String proPlan = 'pro';

  // Egzersiz Tipleri
  static const String wordRecognition = 'word_recognition';
  static const String eyeFocus = 'eye_focus';
  static const String speedReading = 'speed_reading';

  // Zorluk Seviyeleri
  static const int beginnerLevel = 1;
  static const int intermediateLevel = 2;
  static const int advancedLevel = 3;

  // Ücretsiz Plan Limitleri
  static const int freeExerciseLimit = 5;
  static const int freeReadingTimeLimit = 10; // dakika

  // Cache Süreleri
  static const int cacheDuration = 7; // gün

  // Hata Mesajları
  static const String errorGeneral = 'Bir hata oluştu. Lütfen tekrar deneyin.';
  static const String errorConnection = 'İnternet bağlantınızı kontrol edin.';
  static const String errorAuthentication =
      'Oturum süreniz doldu. Lütfen tekrar giriş yapın.';

  // Başarı Mesajları
  static const String successSave = 'Başarıyla kaydedildi.';
  static const String successUpdate = 'Başarıyla güncellendi.';
  static const String successDelete = 'Başarıyla silindi.';

  // Onay Mesajları
  static const String confirmDelete = 'Silmek istediğinize emin misiniz?';
  static const String confirmExit = 'Çıkmak istediğinize emin misiniz?';

  // Button Metinleri
  static const String buttonSave = 'Kaydet';
  static const String buttonUpdate = 'Güncelle';
  static const String buttonDelete = 'Sil';
  static const String buttonCancel = 'İptal';
  static const String buttonConfirm = 'Onayla';
  static const String buttonStart = 'Başla';
  static const String buttonNext = 'İleri';
  static const String buttonPrevious = 'Geri';
  static const String buttonFinish = 'Bitir';
}
