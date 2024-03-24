//
//  ProfileHalfView.swift
//  Gardener
//
//  Created by 유현진 on 3/17/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class ProfileHalfView: UIView {
    
    var disposeBag = DisposeBag()
    
    private lazy var profileImageView: ProfileImageView = {
        let imageView = ProfileImageView()
        return imageView
    }()
    
    private lazy var nickNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        return label
    }()
    
    private lazy var optionStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 10
        stackView.distribution = .equalSpacing
        stackView.axis = .horizontal
        return stackView
    }()
    
    private lazy var isolationButton: UIButton = {
        let button = UIButton()
        var configuration = UIButton.Configuration.plain()
        var attributedTitle = AttributeContainer()
        attributedTitle.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        configuration.attributedTitle = .init("차단", attributes: attributedTitle)
        button.setImage(UIImage(systemName: "xmark.circle", withConfiguration: UIImage.SymbolConfiguration.init(pointSize: 22)), for: .normal)
        button.tintColor = .black
        configuration.imagePlacement = .top
        configuration.imagePadding = 10
        button.configuration = configuration
        return button
    }()
    
    private lazy var expulsionButton: UIButton = {
        let button = UIButton()
        button.tintColor = .red
        var configuration = UIButton.Configuration.plain()
        var attributedTitle = AttributeContainer()
        attributedTitle.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        configuration.attributedTitle = .init("추방", attributes: attributedTitle)
        configuration.image = UIImage(systemName: "rectangle.portrait.and.arrow.right")
        configuration.preferredSymbolConfigurationForImage = .init(pointSize: 22)
        configuration.imagePlacement = .top
        configuration.imagePadding = 10
        button.configuration = configuration
        return button
    }()
    
    private lazy var reportButton: UIButton = {
        let button = UIButton()
        button.tintColor = .red
        var configuration = UIButton.Configuration.plain()
        var attributeTitle = AttributeContainer()
        attributeTitle.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        configuration.attributedTitle = .init("신고", attributes: attributeTitle)
        configuration.image = UIImage(systemName: "light.beacon.min")
        configuration.preferredSymbolConfigurationForImage = .init(pointSize: 22)
        configuration.imagePlacement = .top
        configuration.imagePadding = 10
        button.configuration = configuration
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
        self.backgroundColor = .systemBackground
        self.addSubview(profileImageView)
        self.addSubview(nickNameLabel)
        self.addSubview(optionStackView)
        
        self.optionStackView.addArrangedSubview(isolationButton)
        self.optionStackView.addArrangedSubview(reportButton)
        self.optionStackView.addArrangedSubview(expulsionButton)
        
        
        profileImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(30)
            make.width.height.equalTo(60)
        }
        
        nickNameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.top).offset(10)
            make.left.equalTo(profileImageView.snp.right).offset(15)
        }
        
        optionStackView.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(25)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(60)
        }
        
        isolationButton.snp.makeConstraints { make in
            make.width.equalTo(isolationButton.snp.height)
        }
        
        expulsionButton.snp.makeConstraints { make in
            make.width.equalTo(expulsionButton.snp.height)
        }
        
        reportButton.snp.makeConstraints { make in
            make.width.equalTo(isolationButton.snp.height)
        }
    }
    
    func setData(uid: String){
        FirebaseFirestoreManager.shared.getUserInfoWithRx(uid: uid)
            .bind{ userModel in
                self.profileImageView.setImageView(url: userModel.profileImageURL)
                self.nickNameLabel.text = userModel.nickName
            }.disposed(by: disposeBag)
    }
    
    
    override func layoutSubviews() {
        profileImageView.layer.cornerRadius = 50 * 0.25
//        expulsionButton.layer.cornerRadius = expulsionButton.bounds.height * 0.15
//        isolationButton.layer.cornerRadius = isolationButton.bounds.height * 0.15
//        reportButton.layer.cornerRadius = reportButton.bounds.height * 0.15
    }
}
