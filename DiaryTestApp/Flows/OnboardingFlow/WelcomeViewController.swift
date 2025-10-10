import UIKit

class WelcomeViewController: BaseOnboardingViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Welcome"

       setupUI()
    }

    func setupUI() {

        let welcomeLabel = UIComponentsFactory.makeLabel(text: "I am new to MyNetDiary")
        view.addSubview(welcomeLabel)

        let btnNext = UIComponentsFactory.makePanelButton(title: "Next", width: 120)
        btnNext.addTarget(self, action: #selector(onNext), for: .touchUpInside)

        let bottomPanel = UIComponentsFactory.makeHStackWithButtons(buttons: [btnNext])
        view.addSubview(bottomPanel)

        NSLayoutConstraint.activate([
            welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            welcomeLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            bottomPanel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bottomPanel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            bottomPanel.widthAnchor.constraint(equalToConstant: 150)
        ])
    }

    @objc
    func onNext() {
        coordinator?.onWelcomeSelected()
    }
}
