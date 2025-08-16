# iOS Build Rehberi

## Sorun
GitHub Actions'da iOS build sırasında şu hata alınıyordu:
```
Error (Xcode): No simulator runtime version from [<DVTBuildVersion 22E238>, <DVTBuildVersion 22F77>, <DVTBuildVersion 22G86>, <DVTBuildVersion 23A5308g>] available to use with iphonesimulator SDK version <DVTBuildVersion 22A3362>
```

## Çözüm
Bu hata, macOS runner versiyonu ile Xcode versiyonu arasındaki uyumsuzluktan kaynaklanıyor.

### Yapılan Değişiklikler

1. **macOS Runner Güncellendi**: `macos-latest` → `macos-15` (Sonoma)
2. **Xcode Versiyonu**: Xcode 16.0 kullanılıyor
3. **iOS Deployment Target**: 12.0 → 14.0 güncellendi
4. **Flutter Versiyonu**: 3.24.5 olarak sabitlendi

### Workflow Dosyaları

#### 1. `ios_unsigned.yml` - Temel Build
- macOS 15 kullanır
- Xcode 16.0 ile build yapar
- Codesign yapmaz (unsigned IPA)

#### 2. `ios-build.yml` - Codesign ile Build
- AltStore için codesign yapar
- macOS 15 kullanır
- Xcode 16.0 ile build yapar

#### 3. `ios-build-stable.yml` - Stabil Build (YENİ)
- En temiz build süreci
- Pod cache temizliği yapar
- Daha stabil build için optimize edildi

### Kullanım

1. **GitHub Actions** sekmesine git
2. **Actions** → **iOS Build Stable** seç
3. **Run workflow** butonuna tıkla
4. Build tamamlandığında **Artifacts**'tan IPA'yı indir

### Önemli Notlar

- **macOS 15** kullanılıyor (eski versiyonlar desteklenmiyor)
- **iOS 14.0+** gerekli
- **Xcode 16.0** kullanılıyor
- Build süresi: ~2-3 dakika

### Hata Durumunda

Eğer hala hata alırsanız:
1. `flutter clean` çalıştır
2. `ios/` klasöründe `pod deintegrate` çalıştır
3. `pod install --repo-update` çalıştır
4. Workflow'u tekrar çalıştır

### Yerel Build

Yerel olarak build yapmak için:
```bash
cd ios
pod install
cd ..
flutter build ios --release --no-codesign
```
