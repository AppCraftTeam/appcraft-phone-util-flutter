# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- `ACPhoneEditingController`: при изменении `text` автоматически заменяет цифры trunk-prefix на цифры реального `phoneCode` детектированной страны. Например, ввод `89008007060` без форматтера даёт `text = '79008007060'` (country = RU); с `ACPhoneInputFormatter(mask: '+# (###) ###-##-##')` — `+7 (900) 800-70-60`. Замена хирургическая: трогает только первые N digit-символов (N = длина digits-версии `phoneCode`), сохраняет маску/разделители и позицию курсора по digit-count. Для номеров, где trunk-prefix уже совпадает с `phoneCode` (`+79...`, `+380...`), rewrite не вызывается. Маскирование по-прежнему целиком ответственность форматтера.

### Fixed

- `ACPhoneInputFormatter`: правильная позиция курсора при удалении через маску-разделитель (backspace через `(`, `)`, пробелы).
- `ACPhoneEditingController`: автоматическое удаление одинокого `+` при стирании последней цифры номера.
- `ACPhoneInputFormatter`: обрезка trailing-разделителей после последней цифры — устраняет залипание при удалении (+7, +7 (900) и аналогичных партиальных состояниях).

### Refactored

- `ACPhoneEditingController`: замена `_isRewriting` на `_lastText` — memo-guard + экономия `findPhone` при изменении только selection.

## [1.0.0] - 2026-04-14

### BREAKING CHANGES

- `ACPhoneInputFormatter`: параметры `country` и `onPhoneChanged` удалены. Форматтер теперь принимает один обязательный параметр `mask: String`. Авто-определение страны больше не встроено в форматтер — используйте `ACPhoneEditingController` (auto-detect) или `ACNationalPhoneEditingController` (с явной страной).
- `ACPhoneCountry.telMask` переименован в `nationalMask`. Поведение изменено: скобки и дефисы теперь сохраняются. Для старого поведения (без скобок и дефисов) используйте новый `rawNationalMask`.

### Added

- `ACPhoneCountry.rawMask` — полная маска без `(`, `)`, `-`; разделитель — только пробел.
- `ACPhoneCountry.rawNationalMask` — национальная маска без `(`, `)`, `-`.
- `ACNationalPhoneEditingController` — контроллер ввода национальной части номера с внешне задаваемой страной (`country` через конструктор и сеттер). `rawPhoneNumber` возвращает полный номер, `isValid` валидирует через `ACPhoneUtil`.
- Пример приложения обновлён: две отдельные демо-страницы (`auto_detect_demo_page.dart`, `national_phone_demo_page.dart`) с навигацией из главного экрана.

### Migration

```dart
// BEFORE (0.0.1)
ACPhoneInputFormatter(country: country, onPhoneChanged: (d) => ...);

// AFTER (1.0.0) — полный номер
ACPhoneInputFormatter(mask: country.mask);

// AFTER — только национальная часть
ACPhoneInputFormatter(mask: country.nationalMask);
```

## [0.0.1] - 2026-04-07

### Added

- Phone number parsing and validation (`ACPhoneUtil`)
- Country detection by phone code with 200+ countries
- Localized country names in 36 languages (`ACPhoneCountryLocalizations`)
- Phone number input formatter (`ACPhoneInputFormatter`) with auto-detection and fixed mask modes
- Phone editing controller (`ACPhoneEditingController`) with phone data access and validation
- Example application demonstrating library usage
