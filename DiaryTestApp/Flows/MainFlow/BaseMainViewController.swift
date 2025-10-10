import UIKit

class BaseMainViewController: UIViewController {
    weak var coordinator: MainCoordinator?

    var model: OnboardingViewModel?

    init(coordinator: MainCoordinator? = nil) {
        self.coordinator = coordinator

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
    }
}
