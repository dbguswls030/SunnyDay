//
//  SceneDelegate.swift
//  Gardener
//
//  Created by 유현진 on 2023/03/18.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        
        FirebaseApp.configure()
        
        // 앱 삭제 후 재설치 해도 auth 존재
        if let user = Auth.auth().currentUser{
            Firestore.firestore().collection("user").document(user.uid).getDocument { document, error in
                if let error = error{
                    print("getDocument erorr : \(error.localizedDescription)")
                }
                if let document = document, document.exists{
                    print("exist document")
                    self.window?.rootViewController = MainTabBarController()
                    self.window?.makeKeyAndVisible()
                }else{
                    // 인증번호 검사 후 프로필 설정 화면에서 껐을 경우(프로필 설정까지 완료하지 않은 경우)
                    print("not exist document")
                    self.window?.rootViewController = LoginViewController()
                    self.window?.makeKeyAndVisible()
                }
            }
        }else{
            // 폰 인증 안 받은 경우
            print("not found currentUser")
            self.window?.rootViewController = LoginViewController()
            self.window?.makeKeyAndVisible()
        }
       
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}
extension SceneDelegate{
 
}

