import UIKit

struct UIComponentsFactory {
}

// MARK: - Buttons
extension UIComponentsFactory {
    static func makePanelButton(title: String = "", width: Double? = nil) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .systemOrange
        btn.layer.cornerRadius = 10
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        btn.addConstraint(btn.heightAnchor.constraint(equalToConstant: 44))
        if let width = width {
            btn.addConstraint(btn.widthAnchor.constraint(greaterThanOrEqualToConstant: width))
        }
        return btn
    }
}

// MARK: - Labels
extension UIComponentsFactory {

    static func makeLabel(text: String = "") -> UILabel {
        let label = UILabel()
        label.text = text
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
}

// MARK: - Panels
extension UIComponentsFactory {

    static func makeHStackWithControls(controls: [UIView]) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: controls)
        stackView.axis = .horizontal
        stackView.distribution = .equalCentering
        stackView.translatesAutoresizingMaskIntoConstraints = false

        return stackView
    }

    static func makeHStackWithButtons(buttons: [UIButton]) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: buttons)
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false

        return stackView
    }
}

// MARK: - Other
extension UIComponentsFactory {

    static func makeSelector(with labels: [String], selectedIndex: Int = 0) -> UISegmentedControl {
        let selector = UISegmentedControl(items: labels)
        selector.selectedSegmentIndex = selectedIndex
        selector.translatesAutoresizingMaskIntoConstraints = false

        return selector
    }

    static func makeSimpleTextField(text: String = "", placeholder: String = "") -> UITextField {
        let textField = UITextField()
        textField.text = text
        textField.placeholder = placeholder
        textField.borderStyle = .line
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }
}
