import XCTest
@testable import DeviceTrustSDK_iOS

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

// MARK: - RiskScorer Test senoryaları;
final class RiskScorerTests: XCTestCase {
    /// Tüm caseler olumlu ve 100 puan alınmalı.
    func testAllSignalsSuccess_MaxScore() async {
        let provider = MockDeviceSignalProvider(
            simOperatorName: "Turkcell", // "Emulator" mevcut değil -> 30 puan
            installedApplications: ["com.apple.Calendar"], // "Cydia" yüklü değil -> 40 puan
            osVersion: OperatingSystemVersion(majorVersion: 16, minorVersion: 0, patchVersion: 0) // iOS 14 -> 30 puan
        )

        let scorer = RiskScorer(provider: provider)
        let score = await scorer.scoreCalculation()

        XCTAssertEqual(score.totalScore, 100)
        XCTAssertEqual(score.breakdown["simOperatorNameScore"], 30)
        XCTAssertEqual(score.breakdown["applicationNameScore"], 40)
        XCTAssertEqual(score.breakdown["osVersionScore"], 30)
    }

    func testEmulatorAndCydia_OsOnly() async {
        let provider = MockDeviceSignalProvider(
            simOperatorName: "EmulatorCell", // "Emulator" mevcut -> 0 puan
            installedApplications: ["Cydia", "com.apple.Safari"], // "Cydia" yüklü -> 0 puan
            osVersion: OperatingSystemVersion(majorVersion: 14, minorVersion: 0, patchVersion: 0) // iOS 14 -> 20 puan
        )

        let scorer = RiskScorer(provider: provider)
        let score = await scorer.scoreCalculation()

        XCTAssertEqual(score.totalScore, 20)
        XCTAssertEqual(score.breakdown["simOperatorNameScore"], 0)
        XCTAssertEqual(score.breakdown["applicationNameScore"], 0)
        XCTAssertEqual(score.breakdown["osVersionScore"], 20)
    }
}
