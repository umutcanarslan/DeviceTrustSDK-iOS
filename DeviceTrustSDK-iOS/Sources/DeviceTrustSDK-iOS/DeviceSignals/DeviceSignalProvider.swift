//
//  DeviceSignalProvider.swift
//  DeviceTrustSDK-iOS
//
//  Created by Umut Can Arslan on 12.05.2025.
//

import Foundation

public protocol DeviceSignalProvider: Sendable {
    /// Kullanıcının SIM Operatör adını verir
    func fetchSIMOperatorName() async -> String?

    /// Cihazda yüklü uygulamaların listesi
    func fetchInstalledApplications() async -> [String]

    /// iOS Versiyon bilgisi
    func fetchOSVersion() -> OperatingSystemVersion
}
