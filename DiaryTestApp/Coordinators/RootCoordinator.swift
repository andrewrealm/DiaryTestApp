import UIKit

enum ScreenFlow {
    case onboarding
    case main
}

class RootCoordinator: RootCoordinatorProtocol {

    var navigationController: UINavigationController

    private var currentFlow: FlowCoordinatorProtocol?

    init(navi: UINavigationController) {
        self.navigationController = navi
    }

    func start(from: ScreenFlow) {
        switch from {
        case .onboarding:
            startOnboardingFlow()
        case .main:
            startMainFlow()
        }
    }

    func finish(_ coordinator: FlowCoordinatorProtocol) {
        guard nil != currentFlow else {
            start(from: .onboarding)
            return
        }

        if coordinator === currentFlow, coordinator is OnboardingCoordinator {
            startMainFlow()
        } else if coordinator === currentFlow, coordinator is MainCoordinator {
            startOnboardingFlow()
        }
    }

    private func defaultNavigationController() -> UINavigationController {
        let navi = UINavigationController()
        // Setup default appearance
        return navi
    }

    private func startOnboardingFlow() {
        currentFlow = OnboardingCoordinator(parent: self, navi: navigationController)
        currentFlow?.start()
    }

    private func startMainFlow() {
        currentFlow = MainCoordinator(parent: self, navi: navigationController)
        currentFlow?.start()
    }
}
