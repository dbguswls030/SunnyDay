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
import FirebaseFirestore

class LoginViewController: UIViewController {
    
    private var verificationId = ""
    
    private lazy var loginView: LoginView = {
        let view = LoginView()
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initUI()
        hideKeyboardWhenTouchUpBackground()
    }
    
    private func initUI(){
        self.view.addSubview(loginView)
        loginView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        loginView.phoneNumberTextField.delegate = self
        loginView.certificationNumberTextField.delegate = self
        loginView.phoneNumberTextField.addTarget(self, action: #selector(PhoneNumberTextFieldDidChange(_:)), for: .editingChanged)
        loginView.certificationNumberTextField.addTarget(self, action: #selector(verificationNumberTextFieldDidChange(_:)), for: .editingChanged)
        loginView.submitButton.addTarget(self, action: #selector(verifyPhoneNumber(_:)), for: .touchUpInside)
        loginView.startButton.addTarget(self, action: #selector(start(_:)), for: .touchUpInside)
//        loginView.initUI()
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
extension LoginViewController: UITextFieldDelegate{
    @objc func PhoneNumberTextFieldDidChange(_ sender: Any?){
        if let text = self.loginView.phoneNumberTextField.text{
            if text.count < 11{
                loginView.submitButton.isEnabled = false
                loginView.submitButton.setTitleColor(.lightGray, for: .normal)
            }else{
                loginView.submitButton.isEnabled = true
                loginView.submitButton.setTitleColor(.black, for: .normal)
            }
        }
    }
    
    @objc func verificationNumberTextFieldDidChange(_ sender: Any?){
        if let text = self.loginView.certificationNumberTextField.text{
            if text.count < 6{
                loginView.startButton.isEnabled = false
                loginView.startButton.setTitleColor(.lightGray, for: .normal)
            }else{
                loginView.startButton.isEnabled = true
                loginView.startButton.setTitleColor(.black, for: .normal)
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == loginView.certificationNumberTextField{
            if let char = string.cString(using: String.Encoding.utf8) {
                let isBackSpace = strcmp(char, "\\b")
                if isBackSpace == -92 {
                    return true
                }
            }
            guard loginView.certificationNumberTextField.text!.count < 6 else{
                return false
            }
        }
        if textField == loginView.phoneNumberTextField{
            if let char = string.cString(using: String.Encoding.utf8) {
                let isBackSpace = strcmp(char, "\\b")
                if isBackSpace == -92 {
                    return true
                }
            }
            guard loginView.phoneNumberTextField.text!.count < 11 else{
                return false
            }
        }
        return true
    }
}
extension LoginViewController{
    @objc func verifyPhoneNumber(_ sender: Any?){
        self.dismissKeyboard()
        self.showActivityIndicator(alpha: 0.2)
        PhoneAuthProvider.provider().verifyPhoneNumber("+1 5555555", uiDelegate: nil){ verification, error in
            if let error = error {
                print("phoneNumber verifing error \(error.localizedDescription)")
                self.hideActivityIndicator(alpha: 0.2)
                return
            }
            
            self.loginView.hideLogoImage()
            self.loginView.showWarningLabel()
            self.loginView.submitButton.setTitle("인증번호 다시 받기", for: .normal)
            self.loginView.showCeritificationView()
            self.verificationId = verification ?? ""
            self.hideActivityIndicator(alpha: 0.2)
        }
    }
    
    @objc func start(_ sender: Any?){
        self.dismissKeyboard()
        self.showActivityIndicator(alpha: 0.2)
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: self.verificationId, verificationCode: "123456")
        Auth.auth().signIn(with: credential){ [weak self] success, error in
            guard let self = self else {return}
            if let error = error {
                // TODO: 인증번호 오류 시 팝업
                print("verification error : \(error.localizedDescription)")
                self.hideActivityIndicator(alpha: 0.2)
                return
            }
            
            print("firebase signIn success")
            if let uid = success?.user.uid{
                Firestore.firestore().collection("user").document(uid).getDocument { [weak self] document, error in
                    guard let self = self else {return}
                    if let error = error{
                        print("getDocument erorr : \(error.localizedDescription)")
                        self.hideActivityIndicator(alpha: 0.2)
                        return
                    }
                    self.showActivityIndicator(alpha: 0.2)
                    // 로그아웃 후 재 로그인 시
                    if let document = document, document.exists{
                        print("success get document ")
                        let vc = MainTabBarController()
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true)
                    }else{
                        print("failed get document")
                        let vc = SignUpViewController()
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true)
                    }
                }
            }
        }
    }
}
