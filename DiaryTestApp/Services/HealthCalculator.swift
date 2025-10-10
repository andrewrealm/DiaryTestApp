import Foundation

struct HealthCalculator {

    private let localeService = LocaleService()

    struct Constants {
        static let PA = 1.0
        static let defaultHeight = 170.0
        static let yearInSeconds: TimeInterval = 31_536_000
    }

    /// Calculate `daily calorie budget` based on formulas:
    ///
    ///  For men:
    ///  `662 - 9.53 x ageInYears + PA x (15.91 x weightInKg + 539.6 x heightInMeters)`
    ///
    ///  For women:
    ///  `354 - 6.91 x ageInYears + PA x (9.36 x weightInKg + 726 x heightInMeters)`
    ///
    ///  - Returns : Calculated DCB string
    ///
    func calculateDCBString(dob: Date, gender: Gender, height: Double, weight: Double, unit: MeasurementUnit) -> String {

        let ageInYears = dob.timeIntervalSinceNow / Constants.yearInSeconds
        let weightInKg = unit == .imperial ? localeService.toMetricWeight(weight) : weight
        let heightInMeters = (height == 0 ? Constants.defaultHeight : height) / 100.0
        let measurementUnitString = unit == .imperial ? "" : "kJ"

        switch gender {
        case .male:
            let value = 662 - 9.53 * ageInYears + Constants.PA * (15.91 * weightInKg + 539.6 * heightInMeters)
            return String(format: "%.1f %@", value, measurementUnitString)
        case .female:
            let value = 354 - 6.91 * ageInYears + Constants.PA * (9.36 * weightInKg + 726 * heightInMeters)
            return String(format: "%.1f %@", value, measurementUnitString)
        default:
            return "Unable to calculate to unknown gender."
        }
    }
}
