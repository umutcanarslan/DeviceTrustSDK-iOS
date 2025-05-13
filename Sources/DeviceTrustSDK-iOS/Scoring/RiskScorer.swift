//
//  RiskScorer.swift
//  DeviceTrustSDK-iOS
//
//  Created by Umut Can Arslan on 12.05.2025.
//

import Foundation

public struct RiskScore: Sendable {
    public let totalScore: Int
    public let breakdown: [String:Int]
}

public actor RiskScorer: Sendable {
    private let provider: DeviceSignalProvider

    public init(provider: DeviceSignalProvider) {
        self.provider = provider
    }

    public func scoreCalculation() async -> RiskScore {
        let provider = self.provider

        async let simOperatorName = provider.fetchSIMOperatorName()
        async let installedApplications = provider.fetchInstalledApplications()
        let osVersion = provider.fetchOSVersion()

        /// Operator isim kontrolü, "emulator" içeriyorsa 30 puan ceza
        let simOperatorNameFaul = (await simOperatorName)?
            .lowercased()
            .contains("emulator") == true ? 30 : 0

        /// Cihazda jailbreak kontrolü, "Cydia" yüklüyse 40 puan ceza
        let applicationFaul = (await installedApplications)
            .map { $0.lowercased() }
            .contains("cydia") ? 40 : 0

        /// OS Version kontrolü ve puanlama
        let osVersionScore: Int = {
            switch osVersion.majorVersion {
            case 16...: return 30
            case 14...15: return 20
            case 12...13: return 10
            default: return 0
            }
        }()

        /// Puanlama sistemi 0-100 aralığında sınırlandırıldı
        let scoreAbsoluteValue: Int = osVersionScore - simOperatorNameFaul - applicationFaul
        let totalScore = max(0, min(100, scoreAbsoluteValue))

        return RiskScore(
            totalScore: totalScore,
            breakdown: [
                "simOperatorNameFaul": simOperatorNameFaul,
                "applicationFaul": applicationFaul,
                "osVersionScore": osVersionScore
            ]
        )
    }
}
