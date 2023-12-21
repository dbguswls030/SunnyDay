//
//  CommentCollectionViewCell.swift
//  Gardener
//
//  Created by 유현진 on 12/3/23.
//

import UIKit
import SnapKit

protocol ReplyButtonDelegate: AnyObject{
    func touchUpReplyButton(_ sender: UIReplyButton)
}
class UIReplyButton: UIButton{
    var nickName: String?
    var parentId: Int?
    
    func initReplyButton(nickName: String, parentId: Int){
        self.nickName = nickName
        self.parentId = parentId
    }
}
class UIDeleteButton: UIButton{
    var index: Int?
    
    func initDeleteButton(index: Int){
        self.index = index
    }
}
class CommentCollectionViewCell: UICollectionViewCell {
    
//    weak var delegate: ReplyButtonDelegate?
    
    private lazy var profileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 20
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var nickNameLabel: UILabel = {
        let label = UILabel()
        label.tintColor = .black
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 12, weight: .light)
        return label
    }()
    
    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.tintColor = .black
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.sizeToFit()
        return label
    }()
    
    lazy var replyButton: UIReplyButton = {
        let button = UIReplyButton()
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(systemName: "bubble.right", withConfiguration: UIImage.SymbolConfiguration.init(pointSize: 10))
        configuration.imagePlacement = .all
        var buttonTitle = AttributedString.init("답글쓰기")
        buttonTitle.font = .systemFont(ofSize: 11, weight: .regular)
        configuration.attributedTitle = buttonTitle
        configuration.contentInsets = .init(top: 2, leading: 1, bottom: 2, trailing: 1)
        configuration.imagePadding = 5
        configuration.imagePlacement = .leading
        button.configuration = configuration
        button.setTitleColor(.lightGray, for: .normal)
        button.tintColor = .lightGray
        return button
    }()
    
    private lazy var likeButton: UIButton = {
        let button = UIButton()
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(systemName: "heart", withConfiguration: UIImage.SymbolConfiguration.init(pointSize: 10))
        configuration.imagePlacement = .all
        var buttonTitle = AttributedString.init("좋아요")
        buttonTitle.font = .systemFont(ofSize: 11, weight: .regular)
        configuration.attributedTitle = buttonTitle
        configuration.contentInsets = .init(top: 2, leading: 1, bottom: 2, trailing: 1)
        configuration.imagePadding = 5
        configuration.imagePlacement = .leading
        button.configuration = configuration
        button.setTitleColor(.lightGray, for: .normal)
        button.tintColor = .lightGray
        return button
    }()
    
    lazy var deleteButton: UIDeleteButton = {
        let button = UIDeleteButton()
        button.tintColor = .lightGray
        button.alpha = 0.8
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(systemName: "trash", withConfiguration: UIImage.SymbolConfiguration.init(pointSize: 10))
        button.configuration = configuration
        button.isHidden = true
        return button
    }()
    
    override func prepareForReuse() {
        profileImage.image = nil
        nickNameLabel.text = ""
        dateLabel.text = ""
        contentLabel.text = ""
        profileImage.snp.updateConstraints { make in
            make.left.equalToSuperview().offset(10)
        }
        deleteButton.isHidden = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initUI(){
        self.addSubview(profileImage)
        self.addSubview(nickNameLabel)
        self.addSubview(dateLabel)
        self.addSubview(contentLabel)
        self.addSubview(likeButton)
        self.addSubview(replyButton)
        self.addSubview(deleteButton)
        
        deleteButton.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.width.height.equalTo(45)
        }
        
        profileImage.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(10)
            make.width.height.equalTo(45)
        }
        
        nickNameLabel.snp.makeConstraints { make in
            make.left.equalTo(profileImage.snp.right).offset(12)
            make.top.equalTo(profileImage.snp.top).offset(5)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.left.equalTo(profileImage.snp.right).offset(12)
            make.bottom.equalTo(profileImage.snp.bottom).offset(-5)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.left.equalTo(profileImage.snp.right).offset(12)
            make.top.equalTo(profileImage.snp.bottom).offset(5)
            make.right.equalToSuperview().offset(-10)
            
        }
        
        likeButton.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(10)
            make.left.equalTo(contentLabel.snp.left)
            make.height.equalTo(20)
            make.bottom.equalToSuperview()
        }
        
        replyButton.snp.makeConstraints { make in
            make.centerY.equalTo(likeButton.snp.centerY)
            make.left.equalTo(likeButton.snp.right).offset(10)
            make.height.equalTo(20)
        }
    }
    
    func setHiddenDeleteButton(isHidden: Bool){
        if isHidden == false{
            deleteButton.isHidden = true
        }else{
            deleteButton.isHidden = false
        }
    }
    
    func setContent(content: String){
        self.contentLabel.text = content
        self.contentLabel.sizeToFit()
    }
    
    func setDate(date: Date){
        // TODO: 날짜 케이스, 분, 시간, 일
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let formattedDate = dateFormatter.string(from: date)
        self.dateLabel.text = formattedDate
    }
    
    func setNickName(nickName:String){
        self.nickNameLabel.text = nickName
    }
    
    func setProfileImage(profileImageURL: String){
        self.profileImage.setImage(url: profileImageURL)
    }
    
    func updateConstraintsWithDept(){
        profileImage.snp.updateConstraints { make in
            make.left.equalToSuperview().offset(10 + 45 + 12)
        }
    }
}
