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

// TODO: Firebase에 없은 계정일 시에 회원가입 프로필 생성 ㄱㄱ


class LoginView: UIView{

    private lazy var tempImage: UIImageView = {
        return UIImageView(image: UIImage(named: "ralo"))
    }()
    
    internal lazy var phoneNumberTextField: UITextField = {
        var textField = UITextField()
        textField.placeholder = "휴대폰 번호(- 없이 숫자만 입력)"
        textField.layer.borderColor = UIColor.darkGray.cgColor
        textField.layer.borderWidth = 1.1
        textField.layer.cornerRadius = 5
        textField.leftView = UIView(frame: .init(x: 0, y: 0, width: 13, height: 0))
        textField.leftViewMode = .always
        textField.keyboardType = .numberPad
        return textField
    }()
    
    internal lazy var submitButton: UIButton = {
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
    
    internal lazy var verificationNumberTextField: UITextField = {
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
    
    internal lazy var startButton: UIButton = {
        var button = UIButton()
        button.layer.borderColor = UIColor.darkGray.cgColor
        button.layer.borderWidth = 1.1
        button.layer.cornerRadius = 5
        button.isEnabled = true
        button.backgroundColor = .lightGray
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
    
    private func initUI(){
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
    }
}
