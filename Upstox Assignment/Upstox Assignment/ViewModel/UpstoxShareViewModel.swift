import UIKit

class UpstoxShareViewModel: NSObject {

    // MARK: - Constants

    public static var userHolding: UserHolding? = nil
    private static let url = "https://35dee773a9ec441e9f38d5fc249406ce.api.mockbin.io/"

    // MARK: - Networking

public static func fetchUpstoxSharesUsingJSON(completion: @escaping (_ isSuccess: Bool) -> Void) {
    guard let url = URL(string: Self.url) else {
        print("Invalid URL: \(Self.url)")
        DispatchQueue.main.async {
            completion(false)
        }
        return
    }

    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        // Handle network errors
        if let error = error {
            print("Network error: \(error.localizedDescription)")
            DispatchQueue.main.async {
                completion(false)
            }
            return
        }

        // Validate the HTTP response
        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            print("Server error: \(httpResponse.statusCode)")
            DispatchQueue.main.async {
                completion(false)
            }
            return
        }

        // Ensure data is available
        guard let data = data else {
            print("No data received from server.")
            DispatchQueue.main.async {
                completion(false)
            }
            return
        }

        do {
            // Decode the JSON response
            Self.userHolding = try JSONDecoder().decode(UserHolding.self, from: data)
            print("Successfully decoded user holdings.")
            DispatchQueue.main.async {
                completion(true)
            }
        } catch {
            // Handle decoding errors
            print("Decoding error: \(error.localizedDescription)")
            DispatchQueue.main.async {
                completion(false)
            }
        }
    }

    // Start the network task
    task.resume()
}


    // MARK: - Helpers

    public static func calculatePandLValue(upstoxShare: UpstoxShare) -> Float {
        let currentValue = upstoxShare.ltp * Float(upstoxShare.quantity)
        let investmentValue = upstoxShare.avgPrice * Float(upstoxShare.quantity)
        return currentValue - investmentValue
    }

    public static func calculateTotalCurrentValue() -> Float {
        guard let upstoxSharesArray = userHolding?.userHolding else {
            return 0
        }

        var totalCurrentValue: Float = 0
        for upstoxShare in upstoxSharesArray {
            totalCurrentValue += (upstoxShare.ltp * Float(upstoxShare.quantity))
        }
        return totalCurrentValue
    }

    public static func calculateTotalInvestmentValue() -> Float {
        guard let upstoxSharesArray = userHolding?.userHolding else {
            return 0
        }

        var totalInvestmentValue: Float = 0
        for upstoxShare in upstoxSharesArray {
            totalInvestmentValue += (upstoxShare.avgPrice * Float(upstoxShare.quantity))
        }
        return totalInvestmentValue
    }

    public static func calculateTodaysProfitAndLoss() -> Float {
        guard let upstoxSharesArray = userHolding?.userHolding else {
            return 0
        }

        var todaysPandL: Float = 0
        for upstoxShare in upstoxSharesArray {
            todaysPandL += ((upstoxShare.close - upstoxShare.ltp) * Float(upstoxShare.quantity))
        }
        return todaysPandL
    }
}
