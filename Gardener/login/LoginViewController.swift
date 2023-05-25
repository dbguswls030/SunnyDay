//
//  LoginViewController.swift
//  Gardener
//
//  Created by 유현진 on 2023/04/05.
//

import UIKit
import SnapKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

class LoginViewController: UIViewController {
    
    lazy var loginView: LoginView = {
        let view = LoginView()
        view.googleLoginButtonAction(target: self, action: #selector(googleLogin))
       return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initUI()
        
    }
    
    func initUI(){
        self.view.addSubview(loginView)
        loginView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        loginView.initUI()
    }
    
    @objc func googleLogin(){
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
            guard error == nil else {
                return
            }
            guard let user = result?.user, let idToken = user.idToken?.tokenString
            else {
                return
            }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { result, error in
                // MARK: TODO 로그인 실패 시 처리
                guard error == nil else{
                    print("Firebase SignIn failed")
                    return
                }
                let vc = MainTabBarController()
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            }
        }
    }
    func logout(){
        // 구글 로그아웃
        GIDSignIn.sharedInstance.signOut()
        
        // 파이어베이스 로그아웃
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
        
        // 구글 로그인 연결해제
        GIDSignIn.sharedInstance.disconnect { error in
            guard error == nil else { return }
        }
    }
}
