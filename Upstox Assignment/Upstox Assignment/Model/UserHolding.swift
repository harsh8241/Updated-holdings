import UIKit

struct UserHolding: Codable {
    let data: HoldingData

struct HoldingData: Codable {
    let userHolding: [UpstoxShare]
}
}

