# 📚 Hızlı Okuma Uygulaması

<div align="center">

![Flutter Version](https://img.shields.io/badge/Flutter-3.0.0+-blue.svg)
![Dart Version](https://img.shields.io/badge/Dart-3.0.0+-blue.svg)
![License](https://img.shields.io/badge/license-MIT-purple.svg)

</div>

Okuma hızınızı ve anlama kabiliyetinizi geliştirmenize yardımcı olan modern bir Flutter uygulaması.

## 🚀 Özellikler

- 👁️ Göz odaklama egzersizleri
- 📖 Kelime tanıma alıştırmaları
- ⚡ Hızlı okuma pratikleri
- 📊 Detaylı ilerleme analizi
- 🎯 Kişiselleştirilmiş hedefler
- 🌙 Karanlık/Aydınlık tema desteği
- 📴 Tamamen çevrimdışı çalışır (backend/giriş gerektirmez)

## 📱 Ekran Görüntüleri


## 🛠️ Kurulum

1. Flutter'ı yükleyin (https://flutter.dev/docs/get-started/install)

2. Projeyi klonlayın:
```bash
git clone https://github.com/omerfarukx/Word-Game-Flutter.git
```

3. Bağımlılıkları yükleyin:
```bash
flutter pub get
```

4. Uygulamayı çalıştırın:
```bash
flutter run
```

## 📦 Kullanılan Paketler

- provider: ^6.1.1
- sqflite: ^2.3.0
- shared_preferences: ^2.2.2
- google_fonts: ^6.2.1
- audioplayers: ^6.1.0

## 🏗️ Mimari

Bu proje **feature-first** (özellik odaklı) bir yapıyla geliştirilmiştir. Paylaşılan katmanlar (`core`, `data`, `domain`) cross-cutting olarak kalırken, her ekran/özellik kendi `features/` modülünde toplanır:

```
lib/
├── core/          # Sabitler, DI (service_locator), utils, paylaşılan widget'lar
├── data/          # Veri kaynakları ve repository implementasyonları
├── domain/        # Entity'ler, modeller, repository arayüzleri
└── features/      # Özellik bazlı modüller (her biri screens/providers/widgets içerir)
    ├── auth/             # Giriş / kayıt
    ├── home/             # Ana ekran
    ├── statistics/       # İstatistik takibi
    ├── word_chain/       # Kelime zinciri oyunu
    ├── word_focus/       # Kelime odağı / kelime bulma
    └── exercises/        # Egzersizler
        ├── eye_focus/        # Göz odaklama
        ├── peripheral_vision/ # Çevresel görüş
        ├── word_recognition/ # Kelime tanıma
        ├── speed_reading/    # Hızlı okuma
        ├── word_pairs/       # Kelime çiftleri
        └── letter_search/    # Harf arama
```

## 🤝 Katkıda Bulunma

1. Bu depoyu fork edin
2. Feature branch'i oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'feat: Add amazing feature'`)
4. Branch'inizi push edin (`git push origin feature/amazing-feature`)
5. Pull Request oluşturun


## 📞 İletişim

Ömer Faruk - [@omerfarukx](https://github.com/omerfarukx)

Proje Linki: [https://github.com/omerfarukx/Word-Game-Flutter](https://github.com/omerfarukx/Word-Game-Flutter)
