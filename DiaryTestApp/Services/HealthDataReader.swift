import Foundation
import HealthKit

enum DataReaderError: Error {
    case unableToReadHealthData(String)
}
typealias HealthDataReaderCompletion = (Result<HealthData, Error>) -> Void

protocol HealthDataReaderProtocol {

    /// The resultt of the operation will be returned in `Main` thread
    /// 
    func readHealthData(completion: @escaping HealthDataReaderCompletion)
}

/// Health data collection helper
///
struct HealthData {
    var height: Double = 0 // In cm
    var weight: Double = 0 // In kg
    var sex: Gender = .unknown
    var dob: Date = Date.distantPast

    /// Test for required data
    ///
    var isValid: Bool {
        weight != 0 && sex != .unknown && dob != Date.distantPast
    }
}

/// The `HealthStoreService` wrapper. Removes data reading boilerplate from code.
///
class HealthDataReader {
    private let healthStoreService: HealthStoreServiceProtocol
    private let localeService: LocaleService

    init(localeService: LocaleService, healthStoreService: HealthStoreServiceProtocol) {
        self.localeService = localeService
        self.healthStoreService = healthStoreService
    }

    private func quantityTypesToRead() -> [HKQuantityTypeIdentifier] {
        [
            .height,
            .bodyMass
        ]
    }

    private func characterTypesToRead() -> [HKCharacteristicTypeIdentifier] {
        [
            .biologicalSex,
            .dateOfBirth
        ]
    }

    private func requestPermissions(_ completion: @escaping HealthStorePermissionRequestCompletion) {
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

    private func requestData(_ completion: @escaping HealthDataReaderCompletion) {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let strongSelf = self else {
                completion(.failure(DataReaderError.unableToReadHealthData("Internal reader error.")))
                return
            }
            let group = DispatchGroup()

            var healthData: HealthData = HealthData()

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
extension HealthDataReader {
    private func parseSample(_ sample: HKQuantitySample?, for type: HKQuantityTypeIdentifier, to model: inout HealthData) {
        guard let sample else {
            return
        }

        switch type {
        case HKQuantityTypeIdentifier.height:
            let height = heightFrom(sample)
            model.height = height

        case HKQuantityTypeIdentifier.bodyMass:
            let weight = weightFrom(sample)
            model.weight = weight

        default:
            return
        }
    }

    private func heightFrom(_ sample: HKQuantitySample) -> Double {
        let hkUnit: HKUnit = localeService.isMetric ? HKUnit.meterUnit(with: .centi) : HKUnit.inch()

        return sample.quantity.doubleValue(for: hkUnit)
    }

    private func weightFrom(_ sample: HKQuantitySample) -> Double {
        let hkUnit: HKUnit = localeService.isMetric ? HKUnit.gramUnit(with: .kilo) : HKUnit.pound()

        return sample.quantity.doubleValue(for: hkUnit)
    }

    private func genderFrom(_ sample: HKBiologicalSex?) -> Gender {
        switch sample {
        case .male:
            return .male
        case .female:
            return .female
        default:
            return .unknown
        }
    }

    private func dobleFrom(_ value: DateComponents?) -> Date {
        guard let dateComponents = value else {
            return Date.distantPast
        }

        let date = Calendar.current.date(from: dateComponents)

        return date ?? Date.distantPast
    }
}

extension HealthDataReader: HealthDataReaderProtocol {
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
