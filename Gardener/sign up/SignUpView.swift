//
//  SignUpView.swift
//  Gardener
//
//  Created by 유현진 on 2023/07/17.
//

import UIKit
import SnapKit

class SignUpView: UIView {
    
    private lazy var profileTitle: UILabel = {
        var label = UILabel()
        label.text = "프로필 설정"
        label.font = UIFont.boldSystemFont(ofSize: 22)
        return label
    }()
    
    private lazy var profileTitleBottomLine: BreakLine = {
        var view = BreakLine()
        return view
    }()
    
    lazy var profileImage: UIButton = {
        var button = UIButton()
        button.setImage(UIImage(named: "defaultProfileImage"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.layer.cornerRadius = 60
        button.adjustsImageWhenHighlighted = false
        button.clipsToBounds = true
        return button
    }()
    
    lazy var addImageButtonView: UIView = {
        var view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 15
        return view
    }()
    
    private lazy var addImageButton: UIImageView = {
        var imageView = UIImageView(image: UIImage(systemName: "camera.fill"))
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .gray
        return imageView
    }()
    
    private lazy var noticeLabel: UILabel = {
        var label = UILabel()
        label.text = "프로필 이미지와 닉네임을 설정해주세요."
        label.textColor = .lightGray
        label.font = UIFont.boldSystemFont(ofSize: 10)
        return label
    }()
    
    lazy var nickNameTextField: UITextField = {
        var textField = UITextField()
        textField.placeholder = "닉네임을 입력해주세요.(2~8자 제한)"
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.layer.borderColor = UIColor.darkGray.cgColor
        textField.layer.borderWidth = 1.1
        textField.layer.cornerRadius = 5
        textField.leftView = UIView(frame: .init(x: 0, y: 0, width: 13, height: 0))
        textField.leftViewMode = .always
        textField.returnKeyType = .done
        return textField
    }()
    
    lazy var submitButton: UIButton = {
        var button = UIButton()
        button.setTitle("시작", for: .normal)
        button.tintColor = .white
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        button.backgroundColor = .lightGray
        button.isEnabled = false
        button.layer.cornerRadius = 5
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initUI(){
        backgroundColor = .white
        
        self.addSubview(profileTitle)
        self.addSubview(profileTitleBottomLine)
        self.addSubview(profileImage)
        self.addSubview(addImageButtonView)
        self.addImageButtonView.addSubview(addImageButton)
        self.addSubview(noticeLabel)
        self.addSubview(nickNameTextField)
        self.addSubview(submitButton)

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
        
        profileImage.snp.makeConstraints { make in
            make.top.equalTo(profileTitleBottomLine.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
            make.height.equalTo(120)
            make.width.equalTo(120)
        }
        
        addImageButtonView.snp.makeConstraints { make in
            make.bottom.equalTo(profileImage.snp.bottom).offset(-5)
            make.right.equalTo(profileImage.snp.right)
            make.height.width.equalTo(30)
        }
        
        addImageButton.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        noticeLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImage.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
        }
        
        nickNameTextField.snp.makeConstraints { make in
            make.top.equalTo(noticeLabel.snp.bottom).offset(35)
            make.left.equalToSuperview().offset(50)
            make.right.equalToSuperview().offset(-50)
            make.height.equalTo(40)
        }
        
        submitButton.snp.makeConstraints { make in
            make.bottom.equalTo(self.keyboardLayoutGuide.snp.top).offset(-20)
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().offset(-30)
            make.height.equalTo(45)
        }
    }
}
