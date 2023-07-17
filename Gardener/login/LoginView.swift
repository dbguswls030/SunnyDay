//
//  LoginView.swift
//  Gardener
//
//  Created by 유현진 on 2023/04/05.
//

import UIKit
import SnapKit
import FirebaseCore
import FirebaseAuth

// TODO: 테스트 전화번호로 변경 및 예외처리
// TODO: 인증 성공 시 인증번호 입력창 UI
// TODO: 전화번호 인증 및 UserDefault에 저장

class LoginView: UIView{
    
    private var verificationId = ""
    
    private lazy var tempImage: UIImageView = {
        return UIImageView(image: UIImage(named: "ralo"))
    }()
    
    private lazy var phoneNumberTextField: UITextField = {
        var textField = UITextField()
        textField.placeholder = "휴대폰 번호(- 없이 숫자만 입력)"
        textField.layer.borderColor = UIColor.darkGray.cgColor
        textField.layer.borderWidth = 1.1
        textField.layer.cornerRadius = 5
        textField.leftView = UIView(frame: .init(x: 0, y: 0, width: 13, height: 0))
        textField.leftViewMode = .always
        textField.keyboardType = .numberPad
        textField.delegate = self
        return textField
    }()
    
    private lazy var submitButton: UIButton = {
        var button = UIButton()
        button.layer.borderColor = UIColor.darkGray.cgColor
        button.layer.borderWidth = 1.1
        button.layer.cornerRadius = 5
        button.isEnabled = true
        button.backgroundColor = .lightGray
        button.setTitle("인증하기", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        return button
    }()
    
    private lazy var verificationNumberTextField: UITextField = {
        var textField = UITextField()
        textField.placeholder = "인증번호 입력"
        textField.layer.borderColor = UIColor.darkGray.cgColor
        textField.layer.borderWidth = 1.1
        textField.layer.cornerRadius = 5
        textField.leftView = UIView(frame: .init(x: 0, y: 0, width: 13, height: 0))
        textField.leftViewMode = .always
        textField.keyboardType = .numberPad
        textField.isHidden = true
        return textField
    }()
    
    private lazy var startButton: UIButton = {
        var button = UIButton()
        button.layer.borderColor = UIColor.darkGray.cgColor
        button.layer.borderWidth = 1.1
        button.layer.cornerRadius = 5
        button.isEnabled = true
        button.backgroundColor = .green
        button.setTitle("시작하기", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.isHidden = true
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI(){
        backgroundColor = .white
        self.addSubview(tempImage)
        self.addSubview(phoneNumberTextField)
        self.addSubview(submitButton)
        self.addSubview(verificationNumberTextField)
        self.addSubview(startButton)
        
        tempImage.snp.makeConstraints { make in
            make.top.equalTo(80)
            make.width.equalTo(140)
            make.height.equalTo(140)
            make.centerX.equalToSuperview()
        }
        
        phoneNumberTextField.snp.makeConstraints { make in
            make.top.equalTo(tempImage.snp.bottom).offset(30)
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().offset(-30)
            make.height.equalTo(45)
        }
        
        submitButton.snp.makeConstraints { make in
            make.top.equalTo(phoneNumberTextField.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().offset(-30)
            make.height.equalTo(45)
        }
        
        verificationNumberTextField.snp.makeConstraints { make in
            make.top.equalTo(submitButton.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().offset(-30)
            make.height.equalTo(45)
        }
        
        startButton.snp.makeConstraints { make in
            make.top.equalTo(verificationNumberTextField.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().offset(-30)
            make.height.equalTo(45)
        }
        
        phoneNumberTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        submitButton.addTarget(self, action: #selector(verifyPhoneNumber(_:)), for: .touchUpInside)
        startButton.addTarget(self, action: #selector(start(_:)), for: .touchUpInside)
    }
}
extension LoginView: UITextFieldDelegate{
    @objc func textFieldDidChange(_ sender: Any?){
        if let text = self.phoneNumberTextField.text{
            if text.count < 11{
                submitButton.isEnabled = false
                submitButton.backgroundColor = .lightGray
            }else{
                submitButton.isEnabled = true
                submitButton.backgroundColor = .green
            }
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let char = string.cString(using: String.Encoding.utf8) {
            let isBackSpace = strcmp(char, "\\b")
            if isBackSpace == -92 {
                return true
            }
        }
        guard textField.text!.count < 11 else{
            return false
        }
        return true
    }
}
extension LoginView{
    @objc func verifyPhoneNumber(_ sender: Any?){
        PhoneAuthProvider.provider().verifyPhoneNumber("+1 5555555", uiDelegate: nil){ verification, error in
            if let error = error {
                print("phoneNumber verifing error \(error.localizedDescription)")
                return
            }
            
            self.verificationNumberTextField.isHidden = false
            self.startButton.isHidden = false
            self.verificationId = verification ?? ""
        }
    }
    
    @objc func start(_ sender: Any?){
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: self.verificationId, verificationCode: "123456")
        Auth.auth().signIn(with: credential){ success, error in
            if let error = error {
                print("verification code error \(error.localizedDescription)")
                return
            }
            print("login success")
        }
    }
}
