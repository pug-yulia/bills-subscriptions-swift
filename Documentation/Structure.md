# 📁 bills-subscriptions (SwiftUI + SwiftData)

Рекомендуемая структура проекта для нативного iOS-приложения.

---

## Корень проекта

bills-subscriptions/
├── bills_subscriptionsApp.swift  
├── ContentView.swift  

### bills_subscriptionsApp.swift
- Точка входа приложения
- Подключение `.modelContainer(...)`
- Никакой бизнес-логики

### ContentView.swift
- Временный root-экран
- Позже может быть заменён на `RootView`
- Может содержать `TabView`

---

# 📂 Models/
Хранит **только SwiftData модели и enum’ы**

Models/
├── Category.swift  
├── PaymentEntry.swift  
├── PaymentOccurrence.swift  
└── PaymentEnums.swift  

### Что здесь находится:
- Классы с `@Model`
- enum’ы (PaymentType, RepeatRule)
- Никакой UI
- Никаких ViewModel
- Никакой логики форматирования

---

# 📂 Services/
Логика работы с данными и инфраструктура.

Services/
├── DatabaseSeeder.swift  
├── DatabaseResetter.swift (опционально)  
├── StatisticsService.swift (в будущем)  
└── CurrencyService.swift (в будущем)  

### Что здесь находится:
- Seed базы
- Reset базы
- Расчёт сумм
- Агрегации
- Бизнес-логика, не относящаяся к UI

---

# 📂 Screens/
Экранная логика приложения.

Screens/
├── Root/
│   └── RootView.swift  
│
├── Payments/
│   ├── PaymentsListView.swift  
│   ├── PaymentFormView.swift  
│   └── PaymentDetailsView.swift  
│
├── Categories/
│   ├── CategoriesListView.swift  
│   └── CategoryFormView.swift  
│
├── Settings/
│   ├── SettingsView.swift  
│   └── DeveloperSettingsView.swift  

### Что здесь находится:
- Полноценные экраны
- NavigationStack
- sheet(item:)
- toolbar
- alert
- UI + взаимодействие с SwiftData

---

# 📂 Views/
Переиспользуемые UI-компоненты.

Views/
├── Rows/
│   └── PaymentRow.swift  
│
├── Components/
│   ├── EmptyStateView.swift  
│   ├── CurrencyAmountView.swift  
│   └── PrimaryButton.swift  

### Что здесь находится:
- Мелкие UI элементы
- Строки списков
- Кнопки
- Компоненты без бизнес-логики

---

# 📂 ViewModels/ (опционально)
Добавляется, когда View начинают разрастаться.

ViewModels/
├── PaymentFormViewModel.swift  
└── PaymentsFilterViewModel.swift  

### Что здесь находится:
- @ObservableObject
- @Published свойства
- Логика валидации
- Подготовка данных для View

---

# 📂 Assets.xcassets
- Иконки
- Цвета
- Изображения

---

# 📂 Preview Content
- Preview-ресурсы
- In-memory modelContainer для превью

---

# 🔎 Короткое правило архитектуры

Models → только данные  
Services → логика данных  
Screens → полноценные экраны  
Views → мелкие UI-компоненты  
ViewModels → состояние экранов  

---

