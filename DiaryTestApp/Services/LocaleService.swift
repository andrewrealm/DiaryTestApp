import Foundation

final class LocaleService {

    static let shared = LocaleService()

    private init() {
    }

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

    var isMetric: Bool {
        switch Locale.current.measurementSystem {
        case .us, .uk:
            return false
        default:
            return true
        }
    }

    var measuremenUnit: MeasurementUnit {
        switch Locale.current.measurementSystem {
        case .us, .uk:
                .imperial
        default:
                .metric
        }
    }

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

    func formatNumber(_ number: Double) -> String {
        numberFormatter.locale = Locale.current
        return numberFormatter.string(from: NSNumber(value: number)) ?? ""
    }

    func formatDate(_ dateString: String) -> Date? {
        iso8601DateFormatter.locale = Locale.current
        return iso8601DateFormatter.date(from: dateString)
    }
}
