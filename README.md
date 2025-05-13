# DeviceTrustSDK - iOS

**DeviceTrustSDK**, iOS cihazından alınan sistem sinyallerini (SIM operatör adı, yüklü uygulamalar, OS sürümü) değerlendirerek bir **güven skoru** hesaplayan ve belirlenen eşik değerin altına düşmesi durumunda **attestation** isteği tetikleyen Swift Package Manager tabanlı bir SDK’dır.

---

## 🚀 Özellikler

* **Swift Concurrency & Actor** tabanlı mimari (iOS 13+).
* **Sendable** protokoller ile thread-safe.
* SIM adı, Cydia uygulaması ve OS sürümüne göre 0–100 puan aralığında güven skoru.
* Arka planda `Task.detached` ile periyodik güven denetimi.
* Attestation için asenkron HTTP istemcisi.
* **SOLID** prensiplerine uygun, modüler yapı.

---

## 🏆 Puanlama Sistemi

* Eğer cihazın SIM operatör adında **"emulator"** kelimesi geçiyorsa 0, geçmiyorsa ise 30 puan alınır.
* Eğer cihazda **"Cydia"** adlı uygulama yüklü ise 0, yüklü değil ise 40 puan alınır.
* Cihaz iOS Versiyonu;

    | iOS Versiyon      | Açıklama  |
    | ----------------- | --------- |
    | `iOS ≥ 16`        | 30 Puan   |
    | `14 ≤ iOS < 16`   | 20 Puan   |
    | `12 ≤ iOS < 14`   | 10 Puan   |
    | `iOS < 12 `       | 0 Puan    |

* Puanlama sistemi 100 üzerinden değerlendirilmektedir.
---

## 🛠 Kurulum

### Swift Package Manager

1. Xcode’da **File > Add Packages…**
2. GitHub URL’sini girin:

   ```text
   https://github.com/umutcanarslan/DeviceTrustSDK-iOS.git
   ```
3. Version seçeneğinde `Up to Next Major` (örn. `1.0.0 < 2.0.0`) seçin.
4. Projenizde:

   ```swift
   import DeviceTrustSDK_iOS
   ```

   ile SDK’yı kullanmaya başlayın.

---

## 🧩 Entegrasyon

```swift
import DeviceTrustSDK

let url: String = "https://dev.byterialab.com/attestation"

let manager = DeviceTrustManager.Builder()
    .setEvaluationInterval(60)                    // saniye cinsinden periyot
    .setScoreThreshold(50)                        // attestation eşiği
    .setAttestationURL(URL(string: url)!)         // attestation url
    .setLoggingEnabled(true)                      // konsola log basmayı aç
    .build()

manager.startMonitoring()                         // arkaplanda izlemeye başla
```

* `stopMonitoring()` çağrısıyla izleme sonlandırılabilir.
* `calculateScore() async -> RiskScore` ile anlık skor çekilebilir.

```swift
let totalScore = managerHolder.manager.calculateScore()
```
---

## 📐 Ana Bileşenler

### DeviceSignalProvider

```swift
public protocol DeviceSignalProvider: Sendable {
    func fetchSIMOperatorName() async -> String?
    func fetchInstalledApplications() async -> [String]
    func fetchOSVersion() -> OperatingSystemVersion
}
```

* Soyut protokol. Gerçek ortam verileri yerine testlerde **MockDeviceSignalProvider** ile simüle edilir.

### RiskScorer (actor)

```swift
public actor RiskScorer: Sendable {
    public func scoreCalculation() async -> RiskScore
}
```

* Paralel `async let` kullanarak sinyalleri toplayıp ceza/bonus puanlarını hesaplar.

### AttestationClient

```swift
public struct AttestationClient: @unchecked Sendable {
    public func sendScore(score: RiskScore, device: String, logging: Bool) async
}
```

* `async` HTTP POST ile JSON payload gönderir.

### DeviceTrustManager

```swift
public final class DeviceTrustManager {
    public func startMonitoring()
    public func stopMonitoring()
    public func calculateScore() async -> RiskScore
}
```

* `Task.detached(priority: .background)` ile arkaplanda döngü kurar.
* Eşik altındaysa (Eşik: 50) `AttestationClient` ile isteği tetikler.

---

## 🔧 Konfigürasyon

| Metod                       | Açıklama                                   |
| --------------------------- | ------------------------------------------ |
| `setEvaluationInterval(_:)` | İzleme periyodunu saniye cinsinden ayarlar |
| `setScoreThreshold(_:)`     | Attestation tetikleme eşiğini belirler     |
| `setAttestationURL(_:)`     | Endpoint URL’ini ayarlar                   |
| `setLoggingEnabled(_:)`     | Konsola debug log basmayı açar veya kapar  |

---

## 🧪 Test Edilebilirlik

* **MockDeviceSignalProvider** ile sinyal senaryoları test edilebilir.
* **MockURLProtocol** ile **AttestationClient** HTTP davranışı stub’lanabilir.
* **MockAttestationClient** ile **DeviceTrustManager**’ın attestation çağrısı tetiklenip tetiklenmediği doğrulanabilir.

---

## 📂 Örnek Proje

Basit bir demo SwiftUI uygulaması:

1. SPM ile SDK’yı ekleyin.
2. `DeviceTrustManager`’ı `@StateObject` veya singleton olarak başlatın.
3. `.onAppear` içinde `startMonitoring()` çağırın.
4. `calculateScore()` ile anlık skoru UI’da gösterin.

---

## ⚠️ Bilinen Sınırlamalar

* SIM ve uygulama listesi gerçek değil, testlerde stub’lanmıştır.
* Jailbreak tespiti **gerçek** değil, simülasyon amaçlıdır.
* Minimum iOS 13 gerektirir!

---

## 📝 Lisans

MIT License © 2025 Umut Can Arslan

---

*Bu SDK, ByteriaLab geliştirilmiştir.*
