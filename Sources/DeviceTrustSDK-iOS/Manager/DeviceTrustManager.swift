//
//  DeviceTrustManager.swift
//  DeviceTrustSDK-iOS
//
//  Created by Umut Can Arslan on 12.05.2025.
//

import Foundation
import UIKit

public class DeviceTrustManager {
    private let interval: TimeInterval
    private let threshold: Int
    private let client: AttestationClient
    private let scorer: RiskScorer
    private let logging: Bool

    /// Monitor işini yürütecek `Task`. `nil` ise izleme durdurulmuş demektir.
    private var monitoringTask: Task<Void, Never>?

    private init(
        interval: TimeInterval,
        threshold: Int,
        client: AttestationClient,
        scorer: RiskScorer,
        logging: Bool
    ) {
        self.interval = interval
        self.threshold = threshold
        self.client = client
        self.scorer = scorer
        self.logging = logging
    }

    public class Builder {
        private var interval: TimeInterval = 60
        private var threshold: Int = 50
        private var url: URL?
        private var logging: Bool = false

        public init() {}

        /// İzleme periyodunu saniye cinsinden ayarlar.
        public func setEvaluationInterval(_ second: TimeInterval) -> Builder {
            interval = second
            return self
        }

        /// Skor eşiğini ayarlar.
        public func setScoreThreshold(_ value: Int) -> Builder {
            threshold = value
            return self
        }

        /// Attestation endpoint URL’ini ayarlar.
        public func setAttestationURL(_ attestationUrl: URL) -> Builder {
            url = attestationUrl
            return self
        }

        /// Loglamayı açıp kapatır.
        public func setLoggingEnabled(_ boolingValue: Bool) -> Builder {
            logging = boolingValue
            return self
        }

        public func buildAttestation() -> DeviceTrustManager {
            guard let url = url else {
                fatalError("🔴 Attestation URL must be set before build() 🔴")
            }

            let client = AttestationClient(url: url)
            let scorer = RiskScorer(provider: DefaultDeviceSignalProvider())

            return DeviceTrustManager(
                interval: interval,
                threshold: threshold,
                client: client,
                scorer: scorer,
                logging: logging
            )

        }
    }

    /// Güncel Total Score'a erişim.
    public func calculateScore() async -> RiskScore {
        await scorer.scoreCalculation()
    }

    /// Monitoring’i başlatır.
    public func startMonitoring() {
        stopMonitoring()

        let interval = self.interval
        let threshold = self.threshold
        let logging = self.logging
        let client = self.client
        let scorer = self.scorer

        monitoringTask = Task.detached(priority: .background) {
            // Task iptal edilene kadar devam eder.
            while !Task.isCancelled {
                let score = await scorer.scoreCalculation()

                if logging {
                    print("⚪ RiskScore:", score.totalScore, score.breakdown)
                }

                if score.totalScore < threshold {
                    await client.sendScore(
                        score: score,
                        device: UIDevice.current.model,
                        logging: logging
                    )
                }

                try? await Task.sleep(
                    nanoseconds: UInt64(interval * 1_000_000_000)
                )
            }
        }

        if logging {
            debugPrint("🟠 Monitoring started; interval:", interval, "threshold:", threshold, " 🟠")
        }
    }

    /// Monitoring’i durdurur.
    public func stopMonitoring() {
        monitoringTask?.cancel()
        monitoringTask = nil

        if logging {
            debugPrint("🛑 DeviceTrustManager stopped 🛑")
        }
    }
}
