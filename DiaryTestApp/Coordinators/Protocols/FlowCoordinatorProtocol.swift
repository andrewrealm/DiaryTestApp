import UIKit

protocol RootCoordinatorProtocol: AnyObject {
    var navigationController: UINavigationController { get set }
    func start(from: ScreenFlow)
    func finish(_ coordinator: FlowCoordinatorProtocol)
}

protocol FlowCoordinatorProtocol: AnyObject {
    var navigationController: UINavigationController { get set }
    func start()
}
