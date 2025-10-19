import UIKit

class WeightSelectionViewController: BaseOnboardingViewController {

    var textFieldRef: UITextField = UITextField()
    var weightLabelRef: UILabel = UILabel()
    var unitSwitchRef: UISwitch = UISwitch()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Weight"

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)

        setupUI()
        updateUI()
    }

    func updateUI() {
        if let model = model {
            weightLabelRef.text = model.weightUnitAsString()
            textFieldRef.text = model.weightAsString()
        }
    }
}

// MARK: - Actions
extension WeightSelectionViewController {
    @objc
    private func hideKeyboard() {
        self.view.endEditing(true)
    }

    @objc
    private func onMetricSwitchValueChanged() {
        model?.toggleMeasurementUnit()
        updateUI()
    }

    @objc
    private func onNext() {
        coordinator?.onWeightSelected()
    }
}

// MARK: - UI
extension WeightSelectionViewController {
    private func setupUI() {
        let enterWeightLabel = UIComponentsFactory.makeLabel(text: "Please, enter your weight")
        view.addSubview(enterWeightLabel)

        textFieldRef = UIComponentsFactory.makeSimpleTextField(placeholder: "width")
        textFieldRef.delegate = self
        textFieldRef.keyboardType = .decimalPad
        textFieldRef.autocorrectionType = .no
        view.addSubview(textFieldRef)

        weightLabelRef = UIComponentsFactory.makeLabel(text: model?.weightAsString() ?? "")
        view.addSubview(weightLabelRef)

        NSLayoutConstraint.activate([
            enterWeightLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            enterWeightLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 40),
            enterWeightLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -40),
            textFieldRef.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textFieldRef.topAnchor.constraint(equalTo: enterWeightLabel.bottomAnchor, constant: 20),
            textFieldRef.widthAnchor.constraint(equalToConstant: 60),
            weightLabelRef.leadingAnchor.constraint(equalTo: textFieldRef.trailingAnchor, constant: 10),
            weightLabelRef.centerYAnchor.constraint(equalTo: textFieldRef.centerYAnchor)
        ])

        makeUntiPanelUI()
        makeBottomNavPanelUI()
    }

    private func makeUntiPanelUI() {
        let unitLabel = UIComponentsFactory.makeLabel(text: "Use metric system")
        view.addSubview(unitLabel)

        unitSwitchRef = UISwitch()
        unitSwitchRef.isOn = model?.measurementUnit == .metric ? true : false
        unitSwitchRef.addTarget(self, action: #selector(onMetricSwitchValueChanged), for: .valueChanged)
        view.addSubview(unitSwitchRef)

        let unitPanel = UIComponentsFactory.makeHStackWithControls(controls: [unitLabel, unitSwitchRef])
        unitPanel.spacing = 20
        view.addSubview(unitPanel)

        NSLayoutConstraint.activate([
            unitPanel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            unitPanel.topAnchor.constraint(equalTo: textFieldRef.bottomAnchor, constant: 20)
        ])
    }

    private func makeBottomNavPanelUI() {
        let btnNext = UIComponentsFactory.makePanelButton(title: "Next", width: 120)
        btnNext.addTarget(self, action: #selector(onNext), for: .touchUpInside)

        let bottomPanel = UIComponentsFactory.makeHStackWithButtons(buttons: [btnNext])
        view.addSubview(bottomPanel)

        NSLayoutConstraint.activate([
            bottomPanel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bottomPanel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            bottomPanel.widthAnchor.constraint(equalToConstant: 150)
        ])
    }
}

// MARK: - TextField
extension WeightSelectionViewController: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let model = model {
            textField.text = model.weightAsString()
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        // Approach from internet
        if let textFieldString = textField.text as? NSString {
            let newString = textFieldString.replacingCharacters(in: range, with: string)

            //let floatRegEx = "^([0-9]+)?(\\.([0-9]+)?)?$"
            let floatRegEx = "^([0-9]+)?((\\,|\\.)([0-9]+)?)?$"
            let floatExPredicate = NSPredicate(format: "SELF MATCHES %@", floatRegEx)

            return floatExPredicate.evaluate(with: newString)
        }
        return false
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text, !text.isEmpty else {
            return
        }

        let preparedText = text.replacingOccurrences(of: ",", with: ".")
        model?.weight = Double(preparedText) ?? 0
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
