# 📱 Hızlı Okuma Uygulaması - Ürün Gereksinim Dokümanı (PRD)

<div align="center">

![Status](https://img.shields.io/badge/Status-Development-yellow)
![Version](https://img.shields.io/badge/Version-1.0.0-blue)
![Last Updated](https://img.shields.io/badge/Last%20Updated-2024-green)

</div>

## 📑 İçindekiler
- [Proje Özeti](#-proje-özeti)
- [Özellikler](#-özellikler)
- [Kullanıcı Deneyimi](#-kullanıcı-deneyimi)
- [Teknik Detaylar](#-teknik-detaylar)
- [Veritabanı Yapısı](#-veritabanı-yapısı)
- [Güvenlik](#-güvenlik)
- [Test Stratejisi](#-test-stratejisi)
- [Performans Metrikleri](#-performans-metrikleri)
- [Geliştirme Süreci](#-geliştirme-süreci)

## 📋 Proje Özeti

Hızlı Okuma Uygulaması, kullanıcıların okuma hızını ve anlama kabiliyetini geliştirmeyi amaçlayan modern bir Flutter uygulamasıdır. Uygulama, bilimsel metotları kullanarak kişiselleştirilmiş bir öğrenme deneyimi sunar.

### 🎯 Hedef Kitle
- 📚 Öğrenciler
- 💼 Profesyoneller
- 📖 Kitap severler
- 🎓 Akademisyenler
- 📰 Haber takipçileri

### 📊 Pazar Analizi
- Hedef Pazar Büyüklüğü: 10M+ kullanıcı
- Birincil Pazarlar: Türkiye, ABD, AB ülkeleri
- Rekabet: 5 ana rakip uygulama
- Farklılaştırıcı Özellikler: AI destekli kişiselleştirme, gamification

## 🎨 Özellikler

### 🌟 Temel Özellikler
- Kelime tanıma egzersizleri
  - Kelime çiftleri
  - Hızlı tarama
  - Anlam eşleştirme
- Göz odaklama alıştırmaları
  - Schultz tabloları
  - Takistoskop egzersizleri
  - Periferik görüş geliştirme
- Hızlı kelime tarama pratikleri
  - Metin hızlandırma
  - Kelime grupları
  - Ritim çalışmaları
- İlerleme takibi ve istatistikler
  - Günlük/haftalık/aylık raporlar
  - Başarı grafikleri
  - Karşılaştırmalı analizler
- Kişiselleştirilmiş hedefler
  - AI destekli hedef belirleme
  - Adaptif zorluk seviyesi
  - Özelleştirilmiş egzersiz planları

### 💎 Abonelik Sistemi

#### 🆓 Ücretsiz Plan
- Temel okuma egzersizleri
  - Günlük 3 egzersiz hakkı
  - Temel istatistikler
  - Sınırlı içerik erişimi
- Günlük sınırlı pratik
  - 15 dakika/gün kullanım
  - Basit alıştırmalar
- Basit istatistikler
  - Okuma hızı ölçümü
  - Temel ilerleme grafikleri

#### ⭐ Premium Plan (Aylık: ₺49.99)
- Sınırsız egzersiz
  - Tüm egzersiz tipleri
  - Sınırsız kullanım
- Detaylı istatistikler
  - Gelişmiş analitikler
  - PDF raporlama
  - İlerleme tahminleri
- Özel alıştırmalar
  - Kişiselleştirilmiş içerik
  - Zorluk seviyesi ayarlama
- Reklamsız deneyim

#### 💫 Pro Plan (Yıllık: ₺399.99)
- Premium özellikleri
- Kişiselleştirilmiş antrenman programı
  - AI destekli program oluşturma
  - Haftalık hedef belirleme
  - Performans analizi
- Offline içerik indirme
  - Çevrimdışı çalışma
  - İçerik senkronizasyonu
- Öncelikli destek
  - 7/24 destek
  - Video görüşme desteği
  - Özel eğitmen desteği

## 👥 Kullanıcı Deneyimi

### 📱 UI/UX Prensipleri
- Material Design 3 uyumlu arayüz
- Minimalist ve modern tasarım
- Kolay navigasyon
- Tutarlı renk paleti
- Erişilebilirlik standartlarına uygunluk

### 🎨 Renk Paleti
```
Primary: #2196F3
Secondary: #FFC107
Background: #FFFFFF
Text: #212121
Error: #F44336
Success: #4CAF50
```

### 🔤 Tipografi
```
Başlıklar: Roboto Bold
Alt başlıklar: Roboto Medium
Normal metin: Roboto Regular
Vurgular: Roboto Light Italic
```

## 🛠 Teknik Detaylar

### 🎯 Frontend
- Flutter Framework (3.0.0+)
- Material Design 3
- Provider State Management
- Clean Architecture
- Responsive Design
- Platform-specific optimizasyonlar

### 💾 Backend & Veritabanı
- SQLite (Yerel Depolama)
- Firebase Authentication
- Repository Pattern
- Dependency Injection
- Offline-first yaklaşım
- Veri senkronizasyonu

### 📐 Mimari Yapı
```
lib/
├── core/                  # Temel bileşenler
│   ├── constants/        # Sabitler
│   ├── errors/          # Hata yönetimi
│   ├── theme/           # Tema ayarları
│   └── utils/           # Yardımcı fonksiyonlar
├── data/                 # Veri katmanı
│   ├── datasources/     # Veri kaynakları
│   │   ├── local/      # Yerel depolama
│   │   └── remote/     # Uzak API'ler
│   ├── repositories/    # Repository impl.
│   └── models/          # Veri modelleri
├── domain/              # İş mantığı
│   ├── entities/        # İş nesneleri
│   ├── repositories/    # Repository arayüzleri
│   └── usecases/       # Kullanım durumları
└── presentation/        # UI katmanı
    ├── providers/       # State yönetimi
    ├── screens/         # Ekranlar
    └── widgets/         # UI bileşenleri
```

## 📊 Veritabanı Yapısı

### 💽 Local Storage (SQLite)

#### Users Tablosu
```sql
CREATE TABLE users (
    id TEXT PRIMARY KEY,
    email TEXT NOT NULL,
    name TEXT,
    subscription_type TEXT DEFAULT 'free',
    last_sync_date TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    settings JSON,
    profile_image TEXT
);
```

#### UserProgress Tablosu
```sql
CREATE TABLE user_progress (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id TEXT,
    reading_speed INTEGER,
    comprehension_rate REAL,
    exercise_count INTEGER,
    exercise_date TEXT,
    exercise_type TEXT,
    difficulty_level INTEGER,
    time_spent INTEGER,
    mistakes_made INTEGER,
    FOREIGN KEY (user_id) REFERENCES users (id)
);
```

#### Exercises Tablosu
```sql
CREATE TABLE exercises (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT,
    content TEXT,
    difficulty_level INTEGER,
    type TEXT,
    category TEXT,
    tags TEXT,
    estimated_time INTEGER,
    points INTEGER,
    prerequisites TEXT
);
```

#### Achievements Tablosu
```sql
CREATE TABLE achievements (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id TEXT,
    achievement_type TEXT,
    earned_date TIMESTAMP,
    points INTEGER,
    metadata JSON,
    FOREIGN KEY (user_id) REFERENCES users (id)
);
```

### 🔄 Repository Interfaces

```dart
abstract class IUserRepository {
  Future<User> getUser(String id);
  Future<void> saveUser(User user);
  Future<void> updateUser(User user);
  Future<void> deleteUser(String id);
  Future<void> updateUserSettings(String id, Map<String, dynamic> settings);
  Future<List<Achievement>> getUserAchievements(String id);
}

abstract class IProgressRepository {
  Future<List<Progress>> getUserProgress(String userId);
  Future<void> saveProgress(Progress progress);
  Future<Statistics> getStatistics(String userId);
  Future<List<Progress>> getProgressByDateRange(String userId, DateTime start, DateTime end);
  Future<Map<String, dynamic>> getPerformanceMetrics(String userId);
  Future<void> syncProgress(String userId);
}

abstract class IExerciseRepository {
  Future<List<Exercise>> getExercises(ExerciseFilter filter);
  Future<Exercise> getExerciseById(String id);
  Future<void> saveExerciseResult(String userId, ExerciseResult result);
  Future<List<Exercise>> getRecommendedExercises(String userId);
  Future<void> updateExerciseContent(String id, Map<String, dynamic> content);
}
```

## 🔒 Güvenlik

### 🔐 Kimlik Doğrulama
- Firebase Authentication
- Email/Password
- Google Sign-In
- Apple Sign-In
- Biometric authentication (parmak izi, yüz tanıma)

### 🛡️ Veri Güvenliği
- AES-256 şifreleme
- Secure Storage kullanımı
- SSL/TLS protokolü
- GDPR uyumluluğu

## 🧪 Test Stratejisi

### 🔍 Test Tipleri
1. Birim Testler
   - Repository testleri
   - UseCase testleri
   - Provider testleri
2. Entegrasyon Testleri
   - API entegrasyonları
   - Veritabanı işlemleri
3. UI Testleri
   - Widget testleri
   - Golden testleri
4. Performans Testleri
   - Yük testleri
   - Bellek kullanımı
5. Kullanıcı Kabul Testleri
   - Beta test süreci
   - A/B testleri

## 📈 Performans Metrikleri

### 🎯 Hedef Metrikler
- Uygulama başlatma süresi: < 2 saniye
- Ekran geçiş süresi: < 300ms
- Bellek kullanımı: < 100MB
- Pil tüketimi: < %2/saat
- Çökme oranı: < %0.1

### 📊 İzleme Araçları
- Firebase Analytics
- Firebase Crashlytics
- Custom telemetri
- Performance monitoring

## 🚀 Geliştirme Süreci

### 📅 Sprint Planlaması
- Sprint süresi: 2 hafta
- Daily standup: Her gün 10:00
- Sprint review: Her 2 haftada bir
- Retrospektif: Her ayın son cuma günü

### 🔄 CI/CD Pipeline
1. Kod analizi
   - Static code analysis
   - Lint kuralları kontrolü
2. Test otomasyonu
   - Birim testler
   - Widget testler
3. Build süreci
   - Debug build
   - Release build
4. Deployment
   - Beta dağıtımı
   - Production release

### 📝 Kod Standartları
- Dart style guide uyumu
- Documentation zorunluluğu
- Code review süreci
- Pair programming

### 🎯 Release Kriterleri
1. Test coverage > %80
2. Sıfır kritik hata
3. Performans metriklerini karşılama
4. UX testlerinin tamamlanması

## 📚 Geliştirici Notları
- Minimum Flutter sürümü: 3.0.0
- Dart SDK: >=3.0.0 <4.0.0
- Clean Architecture prensiplerine uygunluk
- Her yeni özellik için birim test zorunluluğu
- Repository Pattern kullanımı
- SOLID prensiplerine uygunluk

## 🔄 Veritabanı Geçiş Stratejisi
1. Yeni Repository implementasyonu
2. Migration scriptlerinin hazırlanması
3. Test ortamında doğrulama
4. Aşamalı production geçişi
5. Rollback planı
6. Veri bütünlüğü kontrolü 