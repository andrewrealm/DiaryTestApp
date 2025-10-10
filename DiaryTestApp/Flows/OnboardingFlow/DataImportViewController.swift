import UIKit

class DataImportViewController: BaseOnboardingViewController {

    private var dataImported: Bool = false

    var infoLabelRef: UILabel = UILabel()
    var btnNextRef: UIButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Import Health data"

        setupUI()
    }

    func updateUI () {
        if let model = model {
            infoLabelRef.text = model.modelDataAsString()
        }
    }

    func setupUI() {

        let importLabel = UIComponentsFactory.makeLabel(text: "Would you like to import your data from Health application?")
        view.addSubview(importLabel)

        infoLabelRef = UIComponentsFactory.makeLabel(text: "")
        infoLabelRef.numberOfLines = 0
        view.addSubview(infoLabelRef)

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
            infoLabelRef.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 40),
            infoLabelRef.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -40),
            infoLabelRef.topAnchor.constraint(equalTo: importLabel.bottomAnchor, constant: 20),
            bottomPanel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bottomPanel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            bottomPanel.widthAnchor.constraint(equalToConstant: 300)
        ])
    }

    @objc
    func onImport() {
        btnNextRef.setTitle("Next", for: .normal)

        model?.importHealthData { [weak self] success, errorString in
            self?.dataImported = success

            guard success else {
                let message = errorString ?? "Unknown error"
                self?.infoLabelRef.text = message
                self?.showAlert(title: "Error", message: message )
                return
            }

            self?.showAlert(title: "Success", message: "Data imported successfully")
            self?.updateUI()
        }
    }

    @objc
    func onNext() {
        coordinator?.onHealthDataSelected(dataImported: dataImported)
    }
}
