import UIKit

class DCBViewController: BaseOnboardingViewController {

    var dcbValueLabelRef: UILabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Daily Calorie Budget"

        setupUI()
     }

     override func viewDidAppear(_ animated: Bool) {
         super.viewDidAppear(animated)

         updateUI()
     }

     func updateUI() {
         if let model = model {
             dcbValueLabelRef.text = model.dcbCalculator()
         }
     }

     func setupUI() {

         let dcbPromptLabel = UIComponentsFactory.makeLabel(text: "Your Daily Calorie Budget")
         view.addSubview(dcbPromptLabel)

         dcbValueLabelRef = UIComponentsFactory.makeLabel(text: "")
         view.addSubview(dcbValueLabelRef)

         let btnNext = UIComponentsFactory.makePanelButton(title: "Next", width: 120)
         btnNext.addTarget(self, action: #selector(onNext), for: .touchUpInside)

         let bottomPanel = UIComponentsFactory.makeHStackWithButtons(buttons: [btnNext])
         view.addSubview(bottomPanel)

         NSLayoutConstraint.activate([
            dcbPromptLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dcbPromptLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -70),
            dcbValueLabelRef.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dcbValueLabelRef.centerYAnchor.constraint(equalTo: dcbPromptLabel.bottomAnchor, constant: 20),
             bottomPanel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
             bottomPanel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
             bottomPanel.widthAnchor.constraint(equalToConstant: 150)
         ])
     }

    @objc
    func onNext() {
        coordinator?.onFinishSelected()
    }
}
