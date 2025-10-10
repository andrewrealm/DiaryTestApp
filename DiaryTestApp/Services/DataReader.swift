import Foundation
import HealthKit

enum DataReaderError: Error {
    case unableToReadHealthData(String)
}

enum MeasurementUnit {
    case imperial, metric
}

struct HealthData {
    var measurementUnit: MeasurementUnit = .metric
    var height: Double = 170 // In cm
    var weight: Double = 0 // In kg
    var sex: Gender = .unknown
    var dob: Date = Date.distantPast

    var isValid: Bool {
        weight != 0 && sex != .unknown && dob != Date.distantPast
    }
}

typealias HealthDataReaderCompletion = (Result<HealthData, Error>) -> Void

protocol DataReaderProtocol {
    func readHealthData(completion: @escaping HealthDataReaderCompletion)
}

class DataReader {
    private let healthStoreService: HealthStoreServiceProtocol
    private let measurementUnit: MeasurementUnit

    init(measurementUnit: MeasurementUnit, healthStoreService: HealthStoreServiceProtocol) {
        self.measurementUnit = measurementUnit
        self.healthStoreService = healthStoreService
    }

    func quantityTypesToRead() -> [HKQuantityTypeIdentifier] {
        [
            .height,
            .bodyMass
        ]
    }

    func characterTypesToRead() -> [HKCharacteristicTypeIdentifier] {
        [
            .biologicalSex,
            .dateOfBirth
        ]
    }

    func requestPermissions(_ completion: @escaping HealthStorePermissionRequestCompletion) {
        let quantityObjects = quantityTypesToRead().map({ HKQuantityType($0) })
        let characterObjects = characterTypesToRead().map({ HKCharacteristicType($0) })

        healthStoreService.requestAccessForRead(types: quantityObjects + characterObjects) { result in
            if case .success(let granted) = result {
                completion(.success(granted))
            } else {
                var errorMessage = "Unable to request health data permissions"
                if case .failure(let error) = result {
                    errorMessage += ": \(error.localizedDescription)"
                }
                completion(.failure(DataReaderError.unableToReadHealthData(errorMessage)))
            }
        }
    }

    func requestData(_ completion: @escaping HealthDataReaderCompletion) {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let strongSelf = self else {
                completion(.failure(DataReaderError.unableToReadHealthData("Internal reader error.")))
                return
            }
            let group = DispatchGroup()

            var healthData: HealthData = HealthData(measurementUnit: strongSelf.measurementUnit)

            strongSelf.quantityTypesToRead().forEach { type in
                group.enter()
                strongSelf.healthStoreService.fetchMostRecentQuantitySample(for: type) { result in
                    if case .success(let quantitySample) = result {
                        strongSelf.parseSample(quantitySample, for: type, to: &healthData)
                    }
                    group.leave()
                }
            }

            group.enter()
            strongSelf.healthStoreService.fetchMostRecentBiologicalSexSample { result in
                if case .success(let bSex) = result {
                    healthData.sex = strongSelf.genderFrom(bSex)
                }

                group.leave()
            }

            group.enter()
            strongSelf.healthStoreService.fetchDOBSample { result in
                if case .success(let dComponents) = result {
                    healthData.dob = strongSelf.dobleFrom(dComponents)
                }

                group.leave()
            }

            group.wait()

            DispatchQueue.main.async {
                completion(.success(healthData))
            }
        }
    }
}

// MARK: - Parsing
extension DataReader {
    func parseSample(_ sample: HKQuantitySample?, for type: HKQuantityTypeIdentifier, to model: inout HealthData) {
        guard let sample else {
            return
        }

        switch type {
        case HKQuantityTypeIdentifier.height:
            let height = heightFrom(sample)
            model.height = height
            print("Height: \(height)")

        case HKQuantityTypeIdentifier.bodyMass:
            let weight = weightFrom(sample)
            model.weight = weight
            print("Weight: \(weight)")
        default:
            return
        }
    }

    func heightFrom(_ sample: HKQuantitySample) -> Double {
        var hkUnit: HKUnit
        switch measurementUnit {
        case .imperial:
            hkUnit = HKUnit.inch()
        case .metric:
            hkUnit = HKUnit.meter()
        }
        let height = sample.quantity.doubleValue(for: hkUnit)

        return height
    }

    func weightFrom(_ sample: HKQuantitySample) -> Double {
        var hkUnit: HKUnit
        switch measurementUnit {
        case .imperial:
            hkUnit = HKUnit.pound()
        case .metric:
            hkUnit = HKUnit.gramUnit(with: .kilo)
        }
        let weight = sample.quantity.doubleValue(for: hkUnit)

        return weight
    }

    func genderFrom(_ sample: HKBiologicalSex?) -> Gender {
        switch sample {
        case .male:
            return .male
        case .female:
            return .female
        default:
            return .unknown
        }
    }

    func dobleFrom(_ value: DateComponents?) -> Date {
        guard let dateComponents = value else {
            return Date.distantPast
        }

        return Calendar.current.date(from: dateComponents)!
    }
}

extension DataReader: DataReaderProtocol {
    func readHealthData(completion: @escaping HealthDataReaderCompletion) {
        requestPermissions { [weak self] result in
            guard case .success(let granted) = result, granted else {
                var message: String = "Unable to read health data"
                if case .failure(let error) = result {
                    message = error.localizedDescription
                }
                DispatchQueue.main.async {
                    completion(.failure(DataReaderError.unableToReadHealthData(message)))
                }
                return
            }

            self?.requestData(completion)
        }
    }
}
