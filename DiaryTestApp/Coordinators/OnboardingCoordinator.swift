import UIKit

class OnboardingCoordinator {
    weak var parentCoordinator: RootCoordinatorProtocol?

    var navigationController: UINavigationController
    var onboardingModel: OnboardingViewModel = OnboardingViewModel(model: OnboardingModel.emptyModel(),
                                                                   healthDataReader: HealthDataReader(localeService: LocaleService(),
                                                                                                      healthStoreService: HealthStoreService()))

    private var dataReader: HealthDataReader?

    init(parent: RootCoordinatorProtocol, navi: UINavigationController) {
        self.parentCoordinator = parent
        self.navigationController = navi
    }
}

extension OnboardingCoordinator: FlowCoordinatorProtocol {
    func start() {
        onBeginSelected()
    }

    private func finish() {
        parentCoordinator?.finish(self)
    }
}

extension OnboardingCoordinator: OnboardingFlowProtocol {

    func onBeginSelected() {
        let welcomeVC = WelcomeViewController(coordinator: self)
        navigationController.setViewControllers([welcomeVC], animated: true)
    }

    func onWelcomeSelected() {
        let genderVC = GenderViewController(coordinator: self)
        genderVC.model = onboardingModel
        navigationController.pushViewController(genderVC, animated: true)
    }

    func onGenderSelected() {
        let dataImportVC = DataImportViewController(coordinator: self)
        dataImportVC.model = onboardingModel
        navigationController.pushViewController(dataImportVC, animated: true)
    }

    func onHealthDataSelected(dataImported: Bool) {
        if dataImported {
            let dcbVC = DCBViewController(coordinator: self)
            dcbVC.model = onboardingModel
            navigationController.pushViewController(dcbVC, animated: true)
        } else {
            let weigtVC = WeightSelectionViewController(coordinator: self)
            weigtVC.model = onboardingModel
            navigationController.pushViewController(weigtVC, animated: true)
        }
    }

    func onWeightSelected() {
        let dobVC = DOBSelectionViewController(coordinator: self)
        dobVC.model = onboardingModel
        navigationController.pushViewController(dobVC, animated: true)
    }

    func onDOBSelected() {
        let dcbVC = DCBViewController(coordinator: self)
        dcbVC.model = onboardingModel
        navigationController.pushViewController(dcbVC, animated: true)
    }

    func onFinishSelected() {
        finish()
    }
}
