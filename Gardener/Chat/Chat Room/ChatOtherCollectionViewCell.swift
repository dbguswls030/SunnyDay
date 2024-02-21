//
//  ChatOtherCollectionViewCell.swift
//  Gardener
//
//  Created by 유현진 on 1/31/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class ChatOtherCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "OtherChatCell"
    
    var disposeBag = DisposeBag()
    
    private lazy var profileImageView: UIImageView = {
        var imageView = UIImageView()
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var nickNameLabel: UILabel = {
        var label = UILabel()
        label.text = " "
        label.font = UIFont.systemFont(ofSize: 11, weight: .light)
        label.textColor = .systemGray
        return label
    }()
    
    private lazy var contentTextView: UITextView = {
        var textView = UITextView()
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.backgroundColor = .lightGray
        textView.layer.masksToBounds = true
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.textContainerInset = UIEdgeInsets(top: 7, left: 8, bottom: 7, right: 8)
        return textView
    }()
    
    private lazy var timeLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10, weight: .light)
        label.textColor = .systemGray
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        nickNameLabel.text = " "
        profileImageView.image = nil
        contentTextView.text = " "
    }
    
    private func initUI(){
        backgroundColor = .clear
        self.addSubview(profileImageView)
        self.addSubview(nickNameLabel)
        self.addSubview(contentTextView)
        self.addSubview(timeLabel)
        
        profileImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(8)
            make.width.height.equalTo(40)
        }
        
        nickNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalTo(profileImageView.snp.right).offset(7)
//            make.height.equalTo(14)
        }
        
        contentTextView.snp.makeConstraints { make in
            make.top.equalTo(nickNameLabel.snp.bottom).offset(5)
            make.left.equalTo(profileImageView.snp.right).offset(7)
            make.right.lessThanOrEqualToSuperview().offset(-80)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.bottom.equalTo(contentTextView.snp.bottom)
            make.left.equalTo(contentTextView.snp.right).offset(3)
        }
    }
    
    func setData(model: ChatMessageModel){
        self.timeLabel.text = model.date.convertDateToCurrentTime()
        self.contentTextView.text = model.message
        getUserInfo(uid: model.uid)
    }
    
    private func getUserInfo(uid: String){
        FirebaseFirestoreManager.shared.getUserInfoWithRx(uid: uid)
            .bind{ userModel in
                self.nickNameLabel.text = userModel.nickName
                self.profileImageView.setImageView(url: userModel.profileImageURL)
            }.disposed(by: disposeBag)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentTextView.layer.cornerRadius = min(contentTextView.bounds.height, contentTextView.bounds.width) * 0.4
        profileImageView.layer.cornerRadius = profileImageView.frame.size.height * 0.25
    }
    
    func getCellHeight() -> CGFloat{
        return nickNameLabel.intrinsicContentSize.height + 5 + contentTextView.intrinsicContentSize.height
    }
    
}
