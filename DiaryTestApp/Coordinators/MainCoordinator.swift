import UIKit

class MainCoordinator {
    weak var parentCoordinator: RootCoordinatorProtocol?
    var navigationController: UINavigationController
    var onboardingModel: OnboardingModel?

    init(parent: RootCoordinatorProtocol, navi: UINavigationController) {
        self.parentCoordinator = parent
        self.navigationController = navi
    }
}

extension MainCoordinator: FlowCoordinatorProtocol {
    func start() {
        let mainVC = MainViewController(coordinator: self)
        mainVC.model = onboardingModel
        navigationController.setViewControllers([mainVC], animated: true)
    }

    private func finish() {
        parentCoordinator?.finish(self)
    }
}

extension MainCoordinator: MainFlowProtocol {
    func onStartFromBeginningSelected() {
        finish()
    }
}
