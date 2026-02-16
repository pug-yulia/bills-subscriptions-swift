import Foundation

enum Money {
    /// minor -> major (с учётом minorUnit)
    static func minorToMajor(_ minor: Int64, minorUnit: Int) -> Double {
        let divider = pow(10.0, Double(minorUnit))
        return Double(minor) / divider
    }

    /// major -> minor (если понадобится)
    static func majorToMinor(_ major: Double, minorUnit: Int) -> Int64 {
        let mult = pow(10.0, Double(minorUnit))
        return Int64((major * mult).rounded())
    }
    
    /// Преобразовать amountMinor из fromCurrency -> toCurrency, возвращает amountMinor в целевой валюте.
    static func convertMinor(
        amountMinor: Int64,
        from: Currency,
        to: Currency,
        rates: [ExchangeRate]
    ) -> Int64 {
        if from.code == to.code { return amountMinor }

        // 1) amountMinor -> major (from)
        let majorFrom = minorToMajor(amountMinor, minorUnit: from.minorUnit)

        // 2) majorFrom -> majorTo через курс
        guard let rate = findRate(from: from.code, to: to.code, rates: rates) else {
            // если курса нет — не ломаем UI, показываем как есть
            return amountMinor
        }
        let majorTo = majorFrom * rate

        // 3) majorTo -> minor (to)
        return majorToMinor(majorTo, minorUnit: to.minorUnit)
    }
    
    static func formatMinor(
           _ amountMinor: Int64,
           currency: Currency
       ) -> String {
           let major = minorToMajor(amountMinor, minorUnit: currency.minorUnit)
           return "\(currency.symbol)\(String(format: "%.\(currency.minorUnit)f", major))"
       }
    // Поддержим и прямой, и обратный курс (если в таблице только один из них)
    private static func findRate(from: String, to: String, rates: [ExchangeRate]) -> Double? {
           if let direct = rates.first(where: { $0.fromCode == from && $0.toCode == to }) {
               return direct.rate
           }
           if let inverse = rates.first(where: { $0.fromCode == to && $0.toCode == from }), inverse.rate != 0 {
               return 1.0 / inverse.rate
           }
           return nil
       }
}
