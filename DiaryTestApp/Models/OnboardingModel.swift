import Foundation

/// By default we support only 'base' gender variations
///
enum Gender: Int {
    case unknown = 0, male, female

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

struct OnboardingModel {
    /// Local measurements unit
    var measurementUnit: MeasurementUnit

    /// User's gender
    var gender: Gender

    /// User's height in 'centimeters'
    var height: Double

    /// User's weight in 'kilograms'
    var weight: Double = 0

    /// User's date of birth
    var dob: Date?

    init(gender: Gender, weight: Double, height: Double, dob: Date? = nil, measurementUnit: MeasurementUnit? = nil) {
        self.measurementUnit = measurementUnit ?? .imperial
        self.gender = gender
        self.dob = dob
        self.height = height
        self.weight = weight
    }
}

extension OnboardingModel {
    static func emptyModel() -> OnboardingModel {
        return OnboardingModel(gender: .male, weight: 0, height: 0, measurementUnit: .imperial)
    }
/*
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
 */
}
