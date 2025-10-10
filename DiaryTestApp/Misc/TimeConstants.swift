import Foundation

struct TimeConstants {
    static let minDateAllowed = Date().addingTimeInterval(-3_153_600_000) // 100 years
    static let maxDateAllowed = Date().addingTimeInterval(-409_968_000) // 13 years
    static let oneYearInSeconds = 31_536_000.0 // 1 year. Also duplicated in HealthCalculator constants...
}
