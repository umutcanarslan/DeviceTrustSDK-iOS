//
//  DefaultDeviceSignalProvider.swift
//  DeviceTrustSDK-iOS
//
//  Created by Umut Can Arslan on 12.05.2025.
//

import Foundation
import CoreTelephony

public class DefaultDeviceSignalProvider: DeviceSignalProvider, @unchecked Sendable {

    public init() {}

    public func fetchSIMOperatorName() async -> String? {
        return nil
    }

    public func fetchInstalledApplications() async -> [String] {
        return []
    }

    public func fetchOSVersion() -> OperatingSystemVersion {
        return ProcessInfo.processInfo.operatingSystemVersion
    }
}
