import Foundation

protocol OnboardingFlowProtocol: AnyObject {
    func onBeginSelected()
    func onWelcomeSelected()
    func onGenderSelected()
    func onHealthDataSelected(dataImported: Bool)
    func onWeightSelected()
    func onDOBSelected()
    func onFinishSelected()
}
