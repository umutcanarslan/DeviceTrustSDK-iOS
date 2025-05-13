//
//  AttestationClient.swift
//  DeviceTrustSDK-iOS
//
//  Created by Umut Can Arslan on 12.05.2025.
//

import Foundation

public struct AttestationClient: @unchecked Sendable {
    private let url: URL
    private let session: URLSession

    public init(url: URL, session: URLSession = .shared) {
        self.url = url
        self.session = session
    }

    /// `logging` parametresi konsola debug mesajı basmayı kontrol eder.
    public func sendScore(
        score: RiskScore,
        device: String,
        logging: Bool
    ) async {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = [
            "score": score.totalScore,
            "device": device
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        do {
            let (_, response) = try await session.data(for: request)

            if let http = response as? HTTPURLResponse, logging {
                if http.statusCode == 200 {
                    debugPrint("🟢 Attestation succeeded 🟢")
                } else {
                    debugPrint("🟣 Attestation returned status: ", http.statusCode, " 🟣")
                }
            }
        } catch {
            if logging {
                debugPrint("🔴 Attestation failed: ", error, " 🔴")
            }
        }
    }
}
