import UIKit

class BaseOnboardingViewController: UIViewController {
    weak var coordinator: OnboardingCoordinator?

    var model: OnboardingViewModel?

    init(coordinator: OnboardingCoordinator? = nil) {
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

extension BaseOnboardingViewController {

    func showAlert(title: String, message: String) {

        /// We don't trust users, so we ensure safety ourselves.
        ///
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alertController, animated: true)
        }
    }
}
