import Foundation

class OnboardingViewModel {

    // Model
    var model: OnboardingModel

    // Services
    private let localeService = LocaleService()
    private let healthCalculator = HealthCalculator()
    private let healthDataReader: HealthDataReaderProtocol

    // Public interface: var
    //
    var measurementUnit: MeasurementUnit {
        get {
            model.measurementUnit
        }
        set {
            model.measurementUnit = newValue
        }
    }

    var height: Double {
        get {
            model.height
        }
        set {
            model.height = newValue
        }
    }

    /// Weight stored in 'kg' and requires conversions during operation depends on local measurement untit
    ///
    var weight: Double {
        get {
            switch model.measurementUnit {
            case .imperial:
                return localeService.toImperialWeight(model.weight)
            case .metric:
                return model.weight
            }
        }
        set {
            switch model.measurementUnit {
            case .imperial:
                model.weight = localeService.toMetricWeight(newValue)
            case .metric:
                model.weight = newValue
            }
        }
    }

    /// Gender
    var gender: Gender {
        get {
            model.gender
        }
        set {
            model.gender = newValue
        }
    }

    /// Date of birth
    ///
    var dob: Date? {
        get {
            model.dob
        }
        set {
            model.dob = newValue
        }
    }

    // Public interface: func
    //
    init (model: OnboardingModel, healthDataReader: HealthDataReaderProtocol) {
        self.model = model
        self.healthDataReader = healthDataReader
        // Correct default value to actual status
        self.model.measurementUnit = localeService.measuremenUnit
    }

    // Helpers:
    //
    func toggleMeasurementUnit() {
        if measurementUnit == .imperial {
            measurementUnit = .metric
        } else {
            measurementUnit = .imperial
        }
    }
}

// MARK: - Convenience
extension OnboardingViewModel {

    func weightUnitAsString() -> String {
        localeService.weightLabel(for: measurementUnit)
    }

    func weightAsString(emptyStringIfZero: Bool = false) -> String {
        guard !weight.isZero, !emptyStringIfZero else {
            return ""
        }
        return String(format: "%.1f", weight)
    }

    func ageAsString() -> String {
        if let dob = dob {
            let age = Date().timeIntervalSince(dob)
            return String(format: "%.0f", age / TimeConstants.oneYearInSeconds)
        }
        return ""
    }

    func dateAsString() -> String {
        dob?.formatted(Date.FormatStyle()
            .locale(localeService.currentLocale())
            .year(.defaultDigits)
            .month(.abbreviated)
            .day(.twoDigits)) ?? "Not set"
    }

    func modelDataAsString() -> String {
        let heightValue = measurementUnit == .imperial ? localeService.toImperialLength(height) : localeService.toMetricLength(height)
        let heighString = String(format: "Height: %.1f %@", heightValue, localeService.lenghtLabel(for: measurementUnit))
        let weightString = weightAsString() + " " + weightUnitAsString()

        return ("\(heighString)\n Weigh: \(weightString)\n Age: \(ageAsString())\n Gender: \(gender.stringValue)\n Date of birth: \(dateAsString())")
    }
}

// MARK: - Health data reader
extension OnboardingViewModel {

    func importHealthData(_ completion: @escaping (Bool, String?) -> Void) {
        healthDataReader.readHealthData { [weak self] result in
            switch result {
            case .success(let healthData):
                if healthData.isValid {
                    self?.model.height = healthData.height
                    self?.model.weight = healthData.weight
                    self?.model.gender = healthData.sex
                    self?.model.dob = healthData.dob
                    completion(true, nil)
                } else {
                    completion(false, "Unable to import weight and date of birth.")
                }
            case .failure(let error):
                completion(false, error.localizedDescription)
            }
        }
    }
}

// MARK: - Calculators
extension OnboardingViewModel {

    func dcbCalculator() -> String {
        guard let dob = dob else {
            return "Please enter your date of birth."
        }
        guard !weight.isZero else {
            return "Please enter your weight."
        }
        guard Gender.unknown != gender else {
            return "Unable to calculate to unknown gender."
        }

        return healthCalculator.calculateDCBString(dob: dob, gender: gender, height: height, weight: weight, unit: measurementUnit)
    }
}
