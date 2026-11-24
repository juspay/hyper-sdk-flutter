import UIKit
import HyperSDK

enum VisaInfiniteAccessTenantConfiguration {
    private static let tenantId = "visabenefits"

    static func hyperServices(clientId: String, payload: [String: Any]) -> HyperServices {
        let tenantParams = HyperTenantParams()
        tenantParams.clientId = clientId
        tenantParams.tenantId = tenantId
        tenantParams.releaseConfigURL = "https://visabenefits.me1.juspay.io/release/visabenefits/\(clientId)-ios"

        var headers = [
            "isCug": isCUG() ? "true" : "false",
        ]
        for key in ["displayIssuerName", "location", "language", "customerId", "environment"] {
            if let value = payload[key] as? String {
                headers[key] = value
            }
        }
        tenantParams.releaseConfigHeaders = headers

        // Leave baseContent unset so HyperSDK uses its standard VIA boot content.
        return HyperServices(tenantParams: tenantParams)
    }

    private static func isCUG() -> Bool {
        guard let devToolsURL = URL(string: "devtools://test") else {
            return false
        }
        return UIApplication.shared.canOpenURL(devToolsURL) || UIDevice.current.name == "Whale999"
    }
}
