//
//  Navigation.swift
//  Weapp
//
//  Created by 香饽饽zizizi on 2024/3/29.
//

import SwiftUI

class WeNavigation {

    static var mainWindow: UIWindow? = nil

    static func getMainUIWindow() -> UIWindow? {
        if let mainWindow = Self.mainWindow {
            return mainWindow
        } else {
            Self.mainWindow = UIApplication.shared.connectedScenes.flatMap({ ($0 as? UIWindowScene)?.windows ?? [] }).first { $0.isKeyWindow }
            return Self.mainWindow
        }
    }

    static func getCurrentNavigationController() -> UINavigationController? {
        if let rootViewController = Self.getMainUIWindow()?.rootViewController {
            
            for rootViewControllerChild in rootViewController.children {
                if let navigationController = rootViewControllerChild as? UINavigationController {
                    return navigationController
                } else {
                    return nil
                }
            }

        }

        return nil
    }

    static func showFullScreen<Content: View>(_ view: Content, animated: Bool = true, completion: (() -> Void)? = nil) -> UINavigationController? {
        if let navigationController = Self.getCurrentNavigationController() {

            let vc = UIHostingController(rootView: view)
            let miniNavigationController = UINavigationController(rootViewController: vc)

            miniNavigationController.navigationBar.isTranslucent = false

            let containerView = WeWrapper {
                NavigationViewController(navigationController: miniNavigationController)
            }
            let containerVC = UIHostingController(rootView: containerView)
            containerVC.modalPresentationStyle = .fullScreen
            containerVC.view.addSubview(miniNavigationController.view)

            navigationController.present(containerVC, animated: animated) {
                completion?()
            }

            return miniNavigationController
        }

        return nil
    }

    static func present<Content: View>(_ view: Content, animated: Bool = true) {
        if let navigationController = Self.getCurrentNavigationController() {
            let delegate = WeNavigationControllerDelegate()
            navigationController.delegate = delegate
            let vc = UIHostingController(rootView: view)

            navigationController.pushViewController(vc, animated: animated)
        }
    }

    static func push<Content: View>(_ view: Content, animated: Bool = true) {
        if let navigationController = Self.getCurrentNavigationController() {
            let vc = UIHostingController(rootView: view)

            navigationController.pushViewController(vc, animated: animated)
        }
    }

    static func pop(animated: Bool = true) {
        if let navigationController = Self.getCurrentNavigationController() {
            navigationController.popViewController(animated: animated)
        }
    }
}

class WeNavigationControllerDelegate: NSObject, UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        return WePresentAnimator()
    }
}

class WePresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        guard let toView = transitionContext.view(forKey: .to) else { return }

        containerView.addSubview(toView)

        toView.transform = CGAffineTransform(translationX: 0, y: containerView.frame.height)

        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            toView.transform = .identity
            toView.alpha = 1
        }) { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
    

}

struct NavigationViewController: UIViewControllerRepresentable {
    let navigationController: UINavigationController
    func makeUIViewController(context: Context) -> UINavigationController {
        return navigationController
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {

    }
}
