import SwiftUI
import SwiftData

struct PaymentEntryRowView: View {
    @Query private var settings: [AppSettings]
    @Query(sort: \Currency.code, order: .forward) private var currencies: [Currency]
    @Query private var rates: [ExchangeRate]

    let entry: PaymentEntry
    let iconSystemName: String
    let subtitle: String

    var body: some View {
        let (amountMinorToShow, currencyToShow) = displayMoney(for: entry)

        HomeRowItemView(
            iconSystemName: iconSystemName,
            title: entry.title,
            subtitle: subtitle,
            rightText: Money.formatMinor(amountMinorToShow, currency: currencyToShow)
        )
    }

    private func displayMoney(for entry: PaymentEntry) -> (Int64, Currency) {
        guard let preferredCode = settings.first?.preferredCurrencyCode else {
            return (entry.amountMinor, entry.currency)
        }

        if entry.currency.code == preferredCode {
            return (entry.amountMinor, entry.currency)
        }

        guard let toCurrency = currencies.first(where: { $0.code == preferredCode }) else {
            return (entry.amountMinor, entry.currency)
        }

        let converted = Money.convertMinor(
            amountMinor: entry.amountMinor,
            from: entry.currency,
            to: toCurrency,
            rates: rates
        )

        return (converted, toCurrency)
    }
}