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
        FirebaseApp.configure()
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
            guard error == nil else {
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString
            else {
                return
            }
            print("email = \(user.profile?.email)")
            print("familyName = \(user.profile?.familyName)")
            print("fullName = \(user.profile?.givenName)")
            print("id = \(user.userID)")
            print("idToken = \(idToken)")
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            
//            Auth.auth().signIn(with: credential) { result, error in
//
//              // At this point, our user is signed in
//            }
            // MARK: TODO
            // 구글 로그인 인증 및 메인 화면 넘어가기
            
            
        }
    }

}
