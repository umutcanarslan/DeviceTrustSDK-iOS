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

        /// Operator isim kontrolü, "emulator" içeriyorsa 0 puan (-30 yerine hiç puan alamayacak) , içermiyor ise +30 puan
        let simOperatorNameScore = (await simOperatorName)?
            .lowercased()
            .contains("emulator") == true ? 0 : 30

        /// Cihazda jailbreak kontrolü, "Cydia" yüklüyse 0 puan (-40 yerine hiç puan alamayacak), yüklü değilse +40 puan
        let applicationNameScore = (await installedApplications)
            .map { $0.lowercased() }
            .contains("cydia") ? 0 : 40

        /// OS Version kontrolü ve puanlama
        let osVersionScore: Int = {
            switch osVersion.majorVersion {
            case 16...: return 30
            case 14...15: return 20
            case 12...13: return 10
            default: return 0
            }
        }()

        /// Puanlama sistemi 0-100 aralığında sınırlandırıldı.
        let scoreAbsoluteValue: Int = osVersionScore + simOperatorNameScore + applicationNameScore
        let totalScore = max(0, min(100, scoreAbsoluteValue))

        return RiskScore(
            totalScore: totalScore,
            breakdown: [
                "simOperatorNameScore": simOperatorNameScore,
                "applicationNameScore": applicationNameScore,
                "osVersionScore": osVersionScore
            ]
        )
    }
}
