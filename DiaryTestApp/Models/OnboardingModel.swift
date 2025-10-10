import Foundation

/// Possible conversions from Int: 0, 1, 2
///
enum Gender {
    case unknown, male, female

    init?(gender: Int) {
        switch gender {
        case 0:
            self = .unknown
        case 1:
            self = .male
        case 2:
            self = .female
        default:
            return nil
        }
    }

    var intValue: Int {
        switch self {
        case .unknown:
            return 0
        case .male:
            return 1
        case .female:
            return 2
        }
    }

    var stringValue: String {
        switch self {
        case .unknown:
            return "Not set"
        case .male:
            return "Male"
        case .female:
            return "Female"
        }
    }
}

extension Gender: CaseIterable {
    static var allCases: [Gender] {
        [.unknown, .male, .female]
    }
}

class OnboardingModel {
    var measurementUnit: MeasurementUnit
    var gender: Gender
    var height: Double
    var dob: Date?

    private var _weight: Double = 0
    var weight: Double {
        get {
            switch measurementUnit {
            case .imperial:
                return LocaleService.shared.toImperialWeight(_weight)
            case .metric:
                return _weight
            }
        }
        set {
            switch measurementUnit {
            case .imperial:
                _weight = LocaleService.shared.toMetricWeight(newValue)
            case .metric:
                _weight = newValue
            }
        }
    }

    init(gender: Gender, weight: Double, height: Double, dob: Date? = nil, measurementUnit: MeasurementUnit? = nil) {
        self.measurementUnit = measurementUnit ?? .imperial
        self.gender = gender
        self.dob = dob
        self.height = height
        self.weight = weight
    }

    func toggleMeasurementUnit() {
        if measurementUnit == .imperial {
            measurementUnit = .metric
        } else {
            measurementUnit = .imperial
        }
    }

    func dcbCalculator() -> String {
        guard let dob = dob else {
            return "Please enter your date of birth."
        }
        guard !weight.isZero else {
            return "Please enter your weight."
        }

        let PA = 1.0
        let ageInYears = dob.timeIntervalSinceNow / 31_536_000
        let weightInKg = measurementUnit == .imperial ? LocaleService.shared.toMetricWeight(weight) : weight
        let heightInMeters = (height == 0 ? 170 : height) / 100
        let measurementUnitString = measurementUnit == .imperial ? "" : "kJ"

        switch gender {
        case .male:
            // 662 - 9.53 x ageInYears + PA x (15.91 x weightInKg + 539.6 x heightInMeters)
            let value = 662 - 9.53 * ageInYears + PA * (15.91 * weightInKg + 539.6 * heightInMeters)
            return String(format: "%.1f %@", value, measurementUnitString)
        case .female:
            // 354 - 6.91 x ageInYears + PA x (9.36 x weightInKg + 726 x heightInMeters)
            let value = 354 - 6.91 * ageInYears + PA * (9.36 * weightInKg + 726 * heightInMeters)
            return String(format: "%.1f %@", value, measurementUnitString)
        default:
            return "Unable to calculate to unknown gender."
        }
    }
}

extension OnboardingModel {
    static func emptyModel() -> OnboardingModel {
        return OnboardingModel(gender: .male, weight: 0, height: 0, measurementUnit: LocaleService.shared.measuremenUnit)
    }

    static func draftFrom(model: OnboardingModel?) -> OnboardingModel {
        guard let model = model else {
            return emptyModel()
        }

        return OnboardingModel(gender: model.gender,
                               weight: model.weight,
                               height: model.height,
                               dob: model.dob,
                               measurementUnit: model.measurementUnit)
    }
}
