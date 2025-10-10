import UIKit

class GenderViewController: BaseOnboardingViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Gender"

       setupUI()
    }

    func setupUI() {

        let selectGenderLabel = UIComponentsFactory.makeLabel(text: "Please, choose your gender")
        view.addSubview(selectGenderLabel)

        let names = Gender.allCases.map({ $0.stringValue })
        let selectedIndex = model?.gender.rawValue ?? 0
        let genderSelector = UIComponentsFactory.makeSelector(with: names, selectedIndex: selectedIndex)
        genderSelector.addTarget(self, action: #selector(onGenderSelected(_:)), for: .valueChanged)
        view.addSubview(genderSelector)

        let btnNext = UIComponentsFactory.makePanelButton(title: "Next", width: 120)
        btnNext.addTarget(self, action: #selector(onNext), for: .touchUpInside)

        let bottomPanel = UIComponentsFactory.makeHStackWithButtons(buttons: [btnNext])
        view.addSubview(bottomPanel)

        NSLayoutConstraint.activate([
            selectGenderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            selectGenderLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            genderSelector.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            genderSelector.topAnchor.constraint(equalTo: selectGenderLabel.bottomAnchor, constant: 20),
            bottomPanel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bottomPanel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            bottomPanel.widthAnchor.constraint(equalToConstant: 150)
        ])
    }

    @objc
    func onGenderSelected(_ sender: UISegmentedControl) {
        model?.gender = Gender(gender: sender.selectedSegmentIndex) ?? .unknown
    }

    @objc
    func onNext() {
        coordinator?.onGenderSelected()
    }
}
