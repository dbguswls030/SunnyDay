//
//  SignUpView.swift
//  Gardener
//
//  Created by 유현진 on 2023/07/17.
//

import UIKit
import SnapKit

class SignUpView: UIView {
    
    private lazy var nickName: UITextField = {
        var textField = UITextField()
        textField.placeholder = "휴대폰 번호(- 없이 숫자만 입력)"
        textField.layer.borderColor = UIColor.darkGray.cgColor
        textField.layer.borderWidth = 1.1
        textField.layer.cornerRadius = 5
        textField.leftView = UIView(frame: .init(x: 0, y: 0, width: 13, height: 0))
        textField.leftViewMode = .always
        return textField
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
        self.addSubview(nickName)
        
        nickName.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().offset(-30)
            make.height.equalTo(45)
        }
    }
}
