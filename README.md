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
- 🔒 Firebase Authentication

## 📱 Ekran Görüntüleri

[Ekran görüntüleri buraya eklenecek]

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

4. Firebase projesini oluşturun ve yapılandırın:
   - Firebase Console'dan yeni proje oluşturun
   - google-services.json dosyasını android/app/ klasörüne ekleyin
   - Firebase Authentication'ı etkinleştirin

5. Uygulamayı çalıştırın:
```bash
flutter run
```

## 📦 Kullanılan Paketler

- firebase_core: ^2.24.2
- firebase_auth: ^4.15.3
- provider: ^6.1.1
- get_it: ^7.6.4
- sqflite: ^2.3.0
- shared_preferences: ^2.2.2

## 🏗️ Mimari

Bu proje Clean Architecture prensiplerine uygun olarak geliştirilmiştir:

```
lib/
├── core/          # Temel utility ve sabitler
├── data/          # Veri katmanı
├── domain/        # İş mantığı katmanı
└── presentation/  # UI katmanı
```

## 🤝 Katkıda Bulunma

1. Bu depoyu fork edin
2. Feature branch'i oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'feat: Add amazing feature'`)
4. Branch'inizi push edin (`git push origin feature/amazing-feature`)
5. Pull Request oluşturun

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır - detaylar için [LICENSE](LICENSE) dosyasına bakın.

## 📞 İletişim

Ömer Faruk - [@omerfarukx](https://github.com/omerfarukx)

Proje Linki: [https://github.com/omerfarukx/Word-Game-Flutter](https://github.com/omerfarukx/Word-Game-Flutter)
