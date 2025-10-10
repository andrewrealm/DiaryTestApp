import UIKit

class DOBSelectionViewController: BaseOnboardingViewController {

    var ageLabelRef: UILabel = UILabel()
    var datePickerRef: UIDatePicker = UIDatePicker()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Day of Birth"

       setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        updateUI()
    }

    func updateUI() {
        if let model = model {
            let dob = model.dob ?? Date().addingTimeInterval(-409_968_000)
            let age = Date().timeIntervalSince(dob)
            let ageString = String(format: "%.0f", age / 31_536_000)
            ageLabelRef.text = ageString
        }
    }

    func setupUI() {

        let agePromptLabel = UIComponentsFactory.makeLabel(text: "Please, enter your age")
        view.addSubview(agePromptLabel)

        ageLabelRef = UIComponentsFactory.makeLabel(text: "age")
        view.addSubview(ageLabelRef)

        datePickerRef = UIDatePicker()
        datePickerRef.datePickerMode = .date
        datePickerRef.preferredDatePickerStyle = .wheels
        datePickerRef.minimumDate = Date().addingTimeInterval(-3_153_600_000) // 100 years
        datePickerRef.maximumDate = Date().addingTimeInterval(-409_968_000) // 13 years
        datePickerRef.addTarget(self, action: #selector(onDateChanged), for: .valueChanged)
        datePickerRef.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(datePickerRef)

        let ageRestrictionLabelRef = UIComponentsFactory.makeLabel(text: "† Age restriction apply")
        ageRestrictionLabelRef.textColor = .gray
        ageRestrictionLabelRef.font = UIFont.systemFont(ofSize: 13, weight: .light)
        view.addSubview(ageRestrictionLabelRef)

        let btnNext = UIComponentsFactory.makePanelButton(title: "Next", width: 120)
        btnNext.addTarget(self, action: #selector(onNext), for: .touchUpInside)

        let bottomPanel = UIComponentsFactory.makeHStackWithButtons(buttons: [btnNext])
        view.addSubview(bottomPanel)

        NSLayoutConstraint.activate([
            agePromptLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            agePromptLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -70),
            ageLabelRef.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            ageLabelRef.topAnchor.constraint(equalTo: agePromptLabel.bottomAnchor, constant: 20),
            datePickerRef.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            datePickerRef.topAnchor.constraint(equalTo: ageLabelRef.bottomAnchor, constant: 20),
            ageRestrictionLabelRef.centerXAnchor.constraint(equalTo: datePickerRef.centerXAnchor),
            ageRestrictionLabelRef.topAnchor.constraint(equalTo: datePickerRef.bottomAnchor, constant: 10),
            bottomPanel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bottomPanel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            bottomPanel.widthAnchor.constraint(equalToConstant: 150)
        ])
    }

    @objc
    func onDateChanged() {
        model?.dob = datePickerRef.date
        updateUI()
    }

    @objc
    func onNext() {
        coordinator?.onDOBSelected()
    }
}
