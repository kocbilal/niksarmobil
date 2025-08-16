# iOS Build ve AltStore Rehberi

Bu rehber, Flutter uygulamanızı GitHub Actions ile build edip AltStore ile test etmek için hazırlanmıştır.

## 🚀 Hızlı Başlangıç

### 1. GitHub Secrets Kurulumu

GitHub repository'nizde aşağıdaki secrets'ları eklemeniz gerekiyor:

#### Gerekli Secrets:
- `BUILD_CERTIFICATE_BASE64`: iOS Developer Certificate (.p12 dosyası) - Base64 encoded
- `P12_PASSWORD`: Certificate şifresi
- `BUILD_PROVISION_PROFILE_BASE64`: Provisioning Profile (.mobileprovision dosyası) - Base64 encoded
- `KEYCHAIN_PASSWORD`: Geçici keychain şifresi (herhangi bir şey olabilir)

#### Opsiyonel Secrets:
- `TEAM_ID`: Apple Developer Team ID'niz

### 2. Certificate ve Provisioning Profile Hazırlama

#### iOS Developer Certificate (.p12):
1. Keychain Access'i açın
2. Certificates > iPhone Developer: [Your Name] bulun
3. Sağ tıklayın > Export
4. .p12 formatında export edin
5. Base64 encode edin:
   ```bash
   base64 -i certificate.p12 | pbcopy
   ```

#### Provisioning Profile:
1. Apple Developer Portal'dan Development provisioning profile indirin
2. Base64 encode edin:
   ```bash
   base64 -i profile.mobileprovision | pbcopy
   ```

### 3. Workflow Kullanımı

#### Otomatik Build:
- `main` veya `develop` branch'e push yapın
- GitHub Actions otomatik olarak çalışacak

#### Manuel Build:
1. GitHub repository'nizde Actions sekmesine gidin
2. "iOS Build with Code Signing" workflow'unu seçin
3. "Run workflow" butonuna tıklayın
4. Build type seçin (development, ad-hoc, app-store)

### 4. IPA İndirme

Build tamamlandıktan sonra:
1. Actions sekmesinde build'e tıklayın
2. "Artifacts" bölümünden IPA'yı indirin
3. AltStore ile telefonunuza yükleyin

## 📱 AltStore Kurulumu

### 1. AltStore Kurulumu
1. [AltStore](https://altstore.io/) sitesinden AltStore'u indirin
2. Mac'inize kurun
3. iPhone'unuzu Mac'e bağlayın
4. AltStore'u iPhone'a yükleyin

### 2. IPA Yükleme
1. İndirdiğiniz IPA dosyasını AltStore'a sürükleyin
2. AltStore otomatik olarak uygulamayı yükleyecek
3. Uygulama ana ekranda görünecek

## 🔧 Sorun Giderme

### Yaygın Hatalar:

#### 1. Code Signing Hatası
```
Code signing is required for product type 'Application' in SDK 'iOS'
```
**Çözüm:** GitHub Secrets'da certificate ve provisioning profile'ların doğru olduğundan emin olun.

#### 2. Provisioning Profile Hatası
```
No provisioning profile found for bundle identifier
```
**Çözüm:** Provisioning profile'da bundle ID'nin `tr.niksarmobil.niksarWebview` olduğundan emin olun.

#### 3. Certificate Hatası
```
No certificate found
```
**Çözüm:** Certificate'ın geçerli olduğundan ve doğru export edildiğinden emin olun.

### Debug İpuçları:
- Workflow loglarını detaylı inceleyin
- Certificate ve provisioning profile'ların süresi dolmamış olmalı
- Bundle ID'ler eşleşmeli

## 📋 Gereksinimler

- macOS 12.0+
- Xcode 15.0+
- Flutter 3.24.0+
- iOS 14.0+ (deployment target)
- Apple Developer Account (ücretsiz hesap yeterli)

## 🔄 Güncelleme

### Flutter Güncelleme:
```yaml
env:
  FLUTTER_VERSION: '3.25.0'  # Yeni versiyon
```

### Xcode Güncelleme:
```yaml
env:
  XCODE_VERSION: '15.1'  # Yeni versiyon
```

## 📞 Destek

Sorun yaşarsanız:
1. GitHub Actions loglarını kontrol edin
2. Certificate ve provisioning profile'ları yeniden export edin
3. Bundle ID'leri kontrol edin
4. iOS deployment target'ı kontrol edin (şu anda 14.0)

## 🎯 Sonraki Adımlar

1. ✅ GitHub Secrets'ları ekleyin
2. ✅ İlk build'i çalıştırın
3. ✅ IPA'yı indirin
4. ✅ AltStore ile test edin
5. ✅ Uygulamayı geliştirmeye devam edin

---

**Not:** Bu workflow development ve testing amaçlıdır. App Store'a yüklemek için farklı ayarlar gerekebilir.
