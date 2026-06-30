# Yayın Kontrol Listesi — Kelime Atölyesi (`com.fargame.kelimeatolyesi`)

## 1) Sürüm numarası
`pubspec.yaml` → `version: 1.0.0+1` (yayın başına `+1` build numarasını artır).

## 2) İmzalama anahtarı (keystore) — BİR KEZ
Anahtarı güvenli sakla, KAYBETME (kaybedersen güncelleme yayınlayamazsın).

```bash
keytool -genkey -v -keystore %USERPROFILE%\kelimeatolyesi-upload.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

`android/key.properties` oluştur (bunu git'e KOYMA — .gitignore'a ekli olmalı):

```
storePassword=•••
keyPassword=•••
keyAlias=upload
storeFile=C:/Users/adana/kelimeatolyesi-upload.jks
```

`android/app/build.gradle` içine imzalama yapılandırması ekle:

```gradle
// android { ... } üstünde:
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
  ...
  signingConfigs {
    release {
      keyAlias keystoreProperties['keyAlias']
      keyPassword keystoreProperties['keyPassword']
      storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
      storePassword keystoreProperties['storePassword']
    }
  }
  buildTypes {
    release {
      signingConfig signingConfigs.release
      // minifyEnabled true / shrinkResources true (isteğe bağlı)
    }
  }
}
```

## 3) Release derlemesi (AAB)
Play Store **App Bundle** ister:
```bash
flutter build appbundle --release
# çıktı: build/app/outputs/bundle/release/app-release.aab
```
Not: Release derlemede reklam kimlikleri otomatik GERÇEK kimliklere döner
(`AdIds.useTest = !kReleaseMode`). Debug'da test reklamı kalır.

## 4) Play Console — uygulama oluştur
- Yeni uygulama → ad: "Kelime Atölyesi: Kelime Oyunu", dil: Türkçe, Oyun, Ücretsiz.
- **Internal testing** track'ine `app-release.aab` yükle (önce burada test et).

## 5) Mağaza listesi
- `store/play_listing_tr.md` içindeki başlık / kısa / tam açıklamayı gir.
- Simge 512×512, feature graphic 1024×500, 2–8 ekran görüntüsü (`store/assets`, `store/screenshots`).

## 6) Gizlilik politikası
- GitHub → repo Settings → Pages → Source: `main`, klasör `/docs` → yayınla.
- URL: `https://omerfarukx.github.io/Word-Game-Flutter/` — Play Console > Uygulama içeriği > Gizlilik politikası alanına yapıştır.

## 7) Uygulama içeriği formları (Play Console > Uygulama içeriği)
- **Reklamlar:** Evet, reklam içerir.
- **Veri güvenliği (Data safety):**
  - Toplanan/işlenen: "Cihaz veya diğer kimlikler" (AdMob, reklam için) → paylaşılır (Google).
  - Kişisel bilgi / konum / kişiler: HAYIR.
  - Veriler aktarımda şifreli: Evet. Silme talebi: yerel veriler uygulamayı kaldırınca silinir.
- **İçerik derecelendirmesi:** anketi doldur → Herkes/3+.
- **Hedef kitle:** 13+ (çocuklara yönelik değil → Aileler programı dışında).
- **Uygulama içi satın almalar:** Evet (Reklamları Kaldır).

## 8) Uygulama içi ürün — Reklamları Kaldır
- Play Console > Para kazanma > Uygulama içi ürünler → **Yönetilen ürün (non-consumable)**
  - Ürün kimliği: **`remove_ads`** (kod bunu bekliyor: `Purchases.removeAdsId`)
  - Fiyat belirle, etkinleştir.
- Lisans test hesabı ekle (Settings > License testing) → test cihazında satın almayı dene.

## 9) AdMob bağlama
- AdMob > Uygulamalar > uygulamayı Play'deki `com.fargame.kelimeatolyesi` ile **bağla**.
- (Önerilir) `app-ads.txt` yayınla.
- Reklam birimleri zaten kodda (release'te gerçek kimlikler):
  App `…~9495792195` · Banner `…/1012621342` · Geçiş `…/3195510093` ·
  Ödüllü `…/4243465516` · Açılış `…/3003938409`.

## 10) Yayın öncesi son kontrol
- [ ] `flutter analyze` temiz
- [ ] Gerçek cihazda release AAB ile test (reklamlar test cihazı olarak işaretlenmeli — AdMob test cihazı ekle; kendi reklamına TIKLAMA)
- [ ] remove_ads satın alma + restore çalışıyor
- [ ] İkon/splash/ad doğru, çökme yok
- [ ] Sürüm/build numarası artırıldı
- [ ] İnceleme için gönder (Production track)
