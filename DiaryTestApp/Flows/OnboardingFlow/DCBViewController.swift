import UIKit

class DCBViewController: BaseOnboardingViewController {

    let welcomeLabel: UILabel = {
        let label = UILabel()
        label.text = "Daily Calorie Budget"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var btnNext = {
        let btn = UIButton(type: .system)
        btn.setTitle("Next", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .systemOrange
        btn.layer.cornerRadius = 10
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(onNext), for: .touchUpInside)
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Daily Calorie Budget"

        view.addSubview(welcomeLabel)
        view.addSubview(btnNext)

        NSLayoutConstraint.activate([
            welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            welcomeLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            btnNext.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            btnNext.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            btnNext.widthAnchor.constraint(equalToConstant: 100),
            btnNext.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    @objc
    func onNext() {
        coordinator?.onFinishSelected()
    }
}
