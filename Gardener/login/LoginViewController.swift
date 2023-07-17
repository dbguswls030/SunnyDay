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

class LoginViewController: UIViewController {
    
    private lazy var loginView: LoginView = {
        let view = LoginView()
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initUI()
        hideKeyboard()
    }
    
    private func initUI(){
        self.view.addSubview(loginView)
        loginView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        loginView.initUI()
    }
    
    private func logout(){
        // 파이어베이스 로그아웃
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}
