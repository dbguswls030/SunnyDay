//
//  LoginView.swift
//  Gardener
//
//  Created by 유현진 on 2023/04/05.
//

import UIKit
import GoogleSignIn
import SnapKit

class LoginView: UIView{
    
    private lazy var tempImage: UIImageView = {
        return UIImageView(image: UIImage(named: "ralo"))
    }()
    
    private lazy var googleLoginButton: GIDSignInButton = {
        var button = GIDSignInButton()
        button.style = .wide
//        button.contentHorizontalAlignment = .center
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
        self.addSubview(googleLoginButton)
        
        tempImage.snp.makeConstraints { make in
            make.top.equalTo(100)
            make.width.equalTo(230)
            make.height.equalTo(230)
            make.centerX.equalToSuperview()
        }
        
        googleLoginButton.snp.makeConstraints { make in
            make.top.equalTo(tempImage.snp.bottom).offset(50)
            make.centerX.equalToSuperview()
            make.left.equalToSuperview().offset(50)
            make.right.equalToSuperview().offset(-50)
        }
    }
    
    func googleLoginButtonAction(target: UIViewController, action: Selector){
        googleLoginButton.addTarget(target, action: action, for: .touchUpInside)
    }
}
