//
//  SceneDelegate.swift
//  Runner
//
//  Created by dongyoonkim on 4/1/26.
//

import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {

    var navigationController: UINavigationController?

    override func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        // FlutterSceneDelegate 가 플러그인에 scene 이벤트를 넘기므로 super 를 먼저 부른다.
        super.scene(scene, willConnectTo: session, options: connectionOptions)

        // Main.storyboard 가 만든 FlutterViewController 를 UINavigationController 로 감싼다.
        guard let controller = window?.rootViewController as? FlutterViewController else { return }
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.setNavigationBarHidden(true, animated: false)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        self.navigationController = navigationController
    }
}
