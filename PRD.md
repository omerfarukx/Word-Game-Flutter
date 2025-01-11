# Hızlı Okuma Uygulaması - Ürün Gereksinim Dokümanı (PRD)

Flutter ile geliştirilmiş, kullanıcıların okuma hızını ve anlama kabiliyetini geliştirmeyi amaçlayan bir mobil uygulama.

## Özellikler

### Temel Özellikler
- Kelime tanıma egzersizleri
- Göz odaklama alıştırmaları
- Hızlı kelime tarama pratikleri
- İlerleme takibi ve istatistikler
- Kişiselleştirilmiş hedefler

### Abonelik Sistemi
#### Ücretsiz Plan
- Temel okuma egzersizleri
- Günlük sınırlı pratik
- Basit istatistikler

#### Premium Plan
- Sınırsız egzersiz
- Detaylı istatistikler
- Özel alıştırmalar
- Reklamsız deneyim

#### Pro Plan
- Premium özellikleri
- Kişiselleştirilmiş antrenman programı
- Offline içerik indirme
- Öncelikli destek

## Teknik Altyapı

### Frontend
- Flutter Framework
- Material Design 3
- Provider State Management
- Clean Architecture

### Backend & Veritabanı
- SQLite (Yerel Depolama)
- Firebase Authentication
- Repository Pattern
- Dependency Injection

### Mimari Yapı
```
lib/
├── core/
│   ├── constants/
│   ├── errors/
│   └── utils/
├── data/
│   ├── datasources/
│   │   ├── local/
│   │   └── remote/
│   ├── repositories/
│   └── models/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── providers/
    ├── screens/
    └── widgets/
```

## Veritabanı Yapısı

### Local Storage (SQLite)
```sql
-- Users Tablosu
CREATE TABLE users (
    id TEXT PRIMARY KEY,
    email TEXT NOT NULL,
    name TEXT,
    subscription_type TEXT DEFAULT 'free',
    last_sync_date TEXT
);

-- UserProgress Tablosu
CREATE TABLE user_progress (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id TEXT,
    reading_speed INTEGER,
    comprehension_rate REAL,
    exercise_count INTEGER,
    exercise_date TEXT,
    FOREIGN KEY (user_id) REFERENCES users (id)
);

-- Exercises Tablosu
CREATE TABLE exercises (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT,
    content TEXT,
    difficulty_level INTEGER,
    type TEXT
);
```

### Repository Interfaces
```dart
abstract class IUserRepository {
  Future<User> getUser(String id);
  Future<void> saveUser(User user);
  Future<void> updateUser(User user);
}

abstract class IProgressRepository {
  Future<List<Progress>> getUserProgress(String userId);
  Future<void> saveProgress(Progress progress);
  Future<Statistics> getStatistics(String userId);
}
```

## Geliştirici Notları
- Minimum Flutter sürümü: 3.0.0
- Dart SDK: >=3.0.0 <4.0.0
- Clean Architecture prensiplerine uygun geliştirme yapılmalı
- Her yeni özellik için birim testleri yazılmalı
- Repository Pattern sayesinde veritabanı değişikliği kolayca yapılabilir

## Veritabanı Geçiş Stratejisi
1. Yeni bir Repository implementasyonu oluştur
2. Yeni veritabanı migration scriptlerini hazırla
3. Test ortamında doğrula
4. Canlı ortamda veri kaybı olmadan geçiş yap 