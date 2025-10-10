import HealthKit

enum HealthServiceError: Error {
    case storeUnavailable(String)
    case authorizationFailed(String)
    case queryPreparationFailed(String)
    case unableToreadSamples(String)
    case unsupportedCharacteristicType(String)
}

typealias HealthStorePermissionRequestCompletion = (Result<Bool, Error>) -> Void
typealias HealthStoreQuantityDataCompletion = (Result<HKQuantitySample?, Error>) -> Void

protocol HealthStoreServiceProtocol {
    func isAvailable() -> Bool
    func requestAccessForRead(types: [HKObjectType], completion: @escaping HealthStorePermissionRequestCompletion)
    func fetchMostRecentQuantitySample(for identifier: HKQuantityTypeIdentifier, _ completion: @escaping HealthStoreQuantityDataCompletion)
    func fetchMostRecentBiologicalSexSample(completion: @escaping (Result<HKBiologicalSex?, Error>) -> Void)
    func fetchDOBSample(completion: @escaping (Result<DateComponents?, Error>) -> Void)
}

///
///
class HealthStoreService {
    private var store: HKHealthStore = HKHealthStore()
}

extension HealthStoreService: HealthStoreServiceProtocol {

    func isAvailable() -> Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    func requestAccessForRead(types: [HKObjectType], completion: @escaping HealthStorePermissionRequestCompletion) {
        guard isAvailable() else {
            completion(.failure(HealthServiceError.storeUnavailable("HealthStore is unavailable")))
            return
        }
        guard types.isEmpty == false else {
            completion(.failure(HealthServiceError.storeUnavailable("HealthStore is unavailable")))
            return
        }

        DispatchQueue.main.async { [weak self] in
            self?.store.requestAuthorization(toShare: [], read: Set(types)) { success, error in
                if let error = error {
                    let errMessage = "Authorization failed: \(error.localizedDescription)"
                    completion(.failure(HealthServiceError.authorizationFailed(errMessage)))
                    return
                }

                completion(.success(true))
            }
        }
    }

    func fetchMostRecentQuantitySample(for identifier: HKQuantityTypeIdentifier, _ completion: @escaping HealthStoreQuantityDataCompletion) {
        guard isAvailable() else {
            completion(.failure(HealthServiceError.storeUnavailable("HealthStore is unavailable")))
            return
        }

        let quantityType = HKQuantityType(identifier)
        requestAccessForRead(types: [quantityType]) { [weak self] result in
            guard case .success = result else {
                var errMessage = "Authorization failed"
                if case .failure(let error) = result {
                    errMessage += ": \(error.localizedDescription)"
                }
                completion(.failure(HealthServiceError.authorizationFailed(errMessage)))
                return
            }

            // Query for samples from start of today until now, sorted by end date descending
            let predicate = HKQuery.predicateForSamples(
                withStart: Calendar.current.startOfDay(for: Date()),
                end: Date(),
                options: .strictStartDate
            )
            let sortDescriptor = NSSortDescriptor(
                key: HKSampleSortIdentifierEndDate,
                ascending: false
            )

            let query = HKSampleQuery(sampleType: quantityType, predicate: predicate, limit: 1, sortDescriptors: [sortDescriptor]) { _, samples, error in
                guard nil != error else {
                    let errMessage = error?.localizedDescription ?? "Unknown error"
                    completion(.failure(HealthServiceError.unableToreadSamples(errMessage)))
                    return
                }

                completion(.success(samples?.first as? HKQuantitySample))
            }
            self?.store.execute(query)
        }
    }

    func fetchMostRecentBiologicalSexSample(completion: @escaping (Result<HKBiologicalSex?, Error>) -> Void) {
        guard isAvailable() else {
            completion(.failure(HealthServiceError.storeUnavailable("HealthStore is unavailable")))
            return
        }

        let characterType = HKCharacteristicType(.biologicalSex)
        requestAccessForRead(types: [characterType]) { [weak self] result in
            guard case .success = result else {
                var errMessage = "Authorization failed"
                if case .failure(let error) = result {
                    errMessage += ": \(error.localizedDescription)"
                }
                completion(.failure(HealthServiceError.authorizationFailed(errMessage)))
                return
            }

            let characterValue = try? self?.store.biologicalSex()
            completion(.success(characterValue?.biologicalSex))
        }
    }

    func fetchDOBSample(completion: @escaping (Result<DateComponents?, Error>) -> Void) {
        guard isAvailable() else {
            completion(.failure(HealthServiceError.storeUnavailable("HealthStore is unavailable")))
            return
        }

        let characterType = HKCharacteristicType(.dateOfBirth)
        requestAccessForRead(types: [characterType]) { [weak self] result in
            guard case .success = result else {
                var errMessage = "Authorization failed"
                if case .failure(let error) = result {
                    errMessage += ": \(error.localizedDescription)"
                }
                completion(.failure(HealthServiceError.authorizationFailed(errMessage)))
                return
            }
            let characterValue = try? self?.store.dateOfBirthComponents()
            completion(.success(characterValue))
        }
    }
}
