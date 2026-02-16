import Foundation

enum Money {
    static func formatMinor(_ amountMinor: Int64, currencyCode: String) -> String {
        let symbol: String = {
            switch currencyCode {
            case "USD": return "$"
            case "RUB": return "₽"
            case "EUR": return "€"
            default: return currencyCode + " "
            }
        }()

        let value = Double(amountMinor) / 100.0
        return "\(symbol)\(String(format: "%.2f", value))"
    }
}
