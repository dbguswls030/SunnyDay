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

class LoginView: UIView{
    
    private lazy var profileTitle: UILabel = {
        var label = UILabel()
        label.text = "전화번호 인증"
        label.font = UIFont.boldSystemFont(ofSize: 22)
        return label
    }()
    
    private lazy var profileTitleBottomLine: BreakLine = {
        var view = BreakLine()
        return view
    }()
    
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
        button.isEnabled = false
        button.setTitle("인증문자 받기", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.setTitleColor(.lightGray, for: .normal)
        return button
    }()
    
    private lazy var certificationExpirationPeriodLabel: UILabel = {
        var label = UILabel()
        label.text = "인증번호 유효기간은 5분 이내입니다."
        label.font = .systemFont(ofSize: 13)
        label.sizeToFit()
        label.isHidden = true
        return label
    }()
    
    internal lazy var certificationNumberTextField: UITextField = {
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
        button.setTitle("인증하기", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.setTitleColor(.lightGray, for: .normal)
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
        self.addSubview(profileTitle)
        self.addSubview(profileTitleBottomLine)
        self.addSubview(tempImage)
        self.addSubview(phoneNumberTextField)
        self.addSubview(submitButton)
        self.addSubview(certificationExpirationPeriodLabel)
        self.addSubview(certificationNumberTextField)
        self.addSubview(startButton)
        
        profileTitle.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(55)
            make.left.equalToSuperview().offset(30)
        }
        
        profileTitleBottomLine.snp.makeConstraints { make in
            make.top.equalTo(profileTitle.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(1)
        }
        
        tempImage.snp.makeConstraints { make in
            make.top.equalTo(profileTitleBottomLine.snp.bottom).offset(45)
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
            make.top.equalTo(phoneNumberTextField.snp.bottom).offset(18)
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().offset(-30)
            make.height.equalTo(45)
        }
        
        certificationExpirationPeriodLabel.snp.makeConstraints { make in
            make.top.equalTo(submitButton.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        
        certificationNumberTextField.snp.makeConstraints { make in
            make.top.equalTo(certificationExpirationPeriodLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().offset(-30)
            make.height.equalTo(45)
        }
        
        startButton.snp.makeConstraints { make in
            make.top.equalTo(certificationNumberTextField.snp.bottom).offset(18)
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().offset(-30)
            make.height.equalTo(45)
        }   
    }
    
    func showWarningLabel(){
        certificationExpirationPeriodLabel.isHidden = false
    }
    
    func showCeritificationView(){
        certificationNumberTextField.isHidden = false
        startButton.isHidden = false
    }
    
    func hideLogoImage(){
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: {
            self.tempImage.snp.updateConstraints { make in
                make.height.equalTo(0)
            }
            self.tempImage.superview?.layoutIfNeeded()
        })
    }
}
