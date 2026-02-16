import Foundation

enum Filtering {

    /// Фильтрация по optional значению (например repeatRuleRaw/category?.id)
    static func byOptional<T, V: Equatable>(
        _ items: [T],
        value: V?,
        keyPath: KeyPath<T, V?>,
        defaultValue: V? = nil
    ) -> [T] {
        guard let value else { return items }
        return items.filter { ($0[keyPath: keyPath] ?? defaultValue) == value }
    }

    /// Фильтрация по не-optional значению
    static func by<T, V: Equatable>(
        _ items: [T],
        value: V?,
        keyPath: KeyPath<T, V>
    ) -> [T] {
        guard let value else { return items }
        return items.filter { $0[keyPath: keyPath] == value }
    }

    /// Фильтрация через произвольное условие (когда keyPath недостаточно)
    static func whereTrue<T>(
        _ items: [T],
        _ predicate: (T) -> Bool
    ) -> [T] {
        items.filter(predicate)
    }
}
