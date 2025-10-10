import UIKit

class DataImportViewController: BaseOnboardingViewController {

    private var dataImported: Bool = false

    var dataReader: DataReader?

    var btnNextRef: UIButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Import Health data"

        setupUI()
    }

    func setupUI() {

        let importLabel = UIComponentsFactory.makeLabel(text: "Would you like to import your data from Health application?")
        view.addSubview(importLabel)

        let btnImport = UIComponentsFactory.makePanelButton(title: "Import", width: 120)
        btnImport.addTarget(self, action: #selector(onImport), for: .touchUpInside)

        btnNextRef = UIComponentsFactory.makePanelButton(title: "Skip", width: 120)
        btnNextRef.addTarget(self, action: #selector(onNext), for: .touchUpInside)

        let bottomPanel = UIComponentsFactory.makeHStackWithButtons(buttons: [btnImport, btnNextRef])
        view.addSubview(bottomPanel)

        NSLayoutConstraint.activate([
            importLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            importLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 40),
            importLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -40),
            bottomPanel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bottomPanel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            bottomPanel.widthAnchor.constraint(equalToConstant: 300)
        ])
    }

    @objc
    func onImport() {
        btnNextRef.setTitle("Next", for: .normal)

        dataReader?.requestData { [weak self] result in
            switch result {
            case .success(let healthData):
                if healthData.isValid {
                    self?.model?.height = healthData.height
                    self?.model?.weight = healthData.weight
                    self?.model?.gender = healthData.sex
                    self?.model?.dob = healthData.dob
                    self?.dataImported = true
                } else {
                    self?.dataImported = false
                    self?.showAlert(title: "Error", message: "Unable to import weight and date of birth.")
                }

            case .failure(let error):
                self?.dataImported = false
                self?.showAlert(title: "Error", message: error.localizedDescription)
            }
        }
    }

    @objc
    func onNext() {
        coordinator?.onHealthDataSelected(dataImported: dataImported)
    }
}
