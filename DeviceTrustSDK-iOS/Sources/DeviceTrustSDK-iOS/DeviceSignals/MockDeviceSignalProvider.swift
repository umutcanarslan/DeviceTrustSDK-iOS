//
//  MockDeviceSignalProvider.swift
//  DeviceTrustSDK-iOS
//
//  Created by Umut Can Arslan on 12.05.2025.
//

import Foundation

public class MockDeviceSignalProvider: DeviceSignalProvider, @unchecked Sendable {
    private let simOperatorName: String?
    private let installedApplications: [String]
    private let osVersion: OperatingSystemVersion

    public init(
        simOperatorName: String?,
        installedApplications: [String],
        osVersion: OperatingSystemVersion
    ) {
        self.simOperatorName = simOperatorName
        self.installedApplications = installedApplications
        self.osVersion = osVersion
    }

    public func fetchSIMOperatorName() async -> String? { simOperatorName }

    public func fetchInstalledApplications() async -> [String] { installedApplications }

    public func fetchOSVersion() -> OperatingSystemVersion { osVersion }
}
