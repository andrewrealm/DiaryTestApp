import Foundation

/// Kind of measurement units
///
enum MeasurementUnit {
    case imperial, metric
}

/// Lightweight locale Units Assistant. Provides a convenient way to work with the user's locale's units of measurement.
///
/// - TODO: Add locale notification changes handler so we can always know actual state
///
struct LocaleService {

    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()

    private let iso8601DateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = .autoupdatingCurrent
        return formatter
    }()
}

// MARK: - Units
extension LocaleService {

    func currentLocale() -> Locale {
        Locale.current
    }

    /// Metric measurement test
    ///
    ///  - Returns: `true` if the user's local unit system is `metric`, and `false` otherwise.
    var isMetric: Bool {
        switch Locale.current.measurementSystem {
        case .us, .uk:
            return false
        default:
            return true
        }
    }

    /// The user's unit measurement system
    ///
    /// - Returns: The `MeasurementUnit` type.
    ///
    var measuremenUnit: MeasurementUnit {
        switch Locale.current.measurementSystem {
        case .us, .uk:
                .imperial
        default:
                .metric
        }
    }

    /// Unit of weight measurement depending on the user's locale
    ///
    ///  - Returns: Formatted `weight`measurement string
    ///
    func weightLabel(for unit: MeasurementUnit) -> String {
        let label: String
        switch unit {
        case .imperial:
            label = "lb"
        case .metric:
            label = "kg"
        }
        return label
    }

    /// Unit of length measurement depending on the user's locale
    ///
    ///  - Returns: Formatted `height`measurement string
    ///
    func lenghtLabel(for unit: MeasurementUnit) -> String {
        let label: String
        switch unit {
        case .imperial:
            label = "ft"
        case .metric:
            label = "m"
        }
        return label
    }
}

// MARK: - Conversions
extension LocaleService {

    func toMetricLength(_ imperialLength: Double) -> Double {
        return imperialLength * 0.3048
    }

    func toImperialLength(_ metricLength: Double) -> Double {
        return metricLength * 3.28084
    }

    func toMetricWeight(_ imperialWeight: Double) -> Double {
        return imperialWeight * 0.453592
    }

    func toImperialWeight(_ metricWeight: Double) -> Double {
        return metricWeight * 2.20462
    }
}

// MARK: - Formatters
extension LocaleService {

//    func formatNumber(_ number: Double) -> String {
//        numberFormatter.locale = Locale.current
//        return numberFormatter.string(from: NSNumber(value: number)) ?? ""
//    }
//
//    func formatDate(_ dateString: String) -> Date? {
//        iso8601DateFormatter.locale = Locale.current
//        return iso8601DateFormatter.date(from: dateString)
//    }
}
