import SwiftUI
import SwiftData

struct PaymentEntriesListView: View {
    @Environment(\.modelContext) private var context

    // Подтягиваем настройки + валюты + курсы, чтобы UI реагировал на их изменения
    @Query private var settings: [AppSettings]
    @Query(sort: \Currency.code, order: .forward) private var currencies: [Currency]
    @Query private var rates: [ExchangeRate]

    let entries: [PaymentEntry]
    let emptyText: String
    let iconProvider: (PaymentEntry) -> String
    let subtitleProvider: (PaymentEntry) -> String

    var allowDelete: Bool = false

    var body: some View {
        if entries.isEmpty {
            Text(emptyText)
                .foregroundStyle(.gray)
                .padding(.top, 40)
        } else {
            VStack(spacing: 10) {
                ForEach(entries) { entry in
                    let (amountMinorToShow, currencyToShow) = displayMoney(for: entry)

                    HomeRowItemView(
                        iconSystemName: iconProvider(entry),
                        title: entry.title,
                        subtitle: subtitleProvider(entry),
                        rightText: Money.formatMinor(amountMinorToShow, currency: currencyToShow)
                    )
                }
            }
        }
    }

    // MARK: - Money display

    private func displayMoney(for entry: PaymentEntry) -> (Int64, Currency) {
        // Если настроек нет — показываем как есть
        guard let preferredCode = settings.first?.preferredCurrencyCode else {
            return (entry.amountMinor, entry.currency)
        }

        // Если валюта записи уже совпадает — без конвертации
        if entry.currency.code == preferredCode {
            return (entry.amountMinor, entry.currency)
        }

        // Находим целевую валюту по коду из настроек
        guard let toCurrency = currencies.first(where: { $0.code == preferredCode }) else {
            return (entry.amountMinor, entry.currency)
        }

        // Конвертируем через курсы
        let converted = Money.convertMinor(
            amountMinor: entry.amountMinor,
            from: entry.currency,
            to: toCurrency,
            rates: rates
        )

        return (converted, toCurrency)
    }
}
