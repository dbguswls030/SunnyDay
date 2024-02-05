//
//  ChatOtherCollectionViewCell.swift
//  Gardener
//
//  Created by 유현진 on 1/31/24.
//

import UIKit
import SnapKit

class ChatOtherCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "OtherChatCell"
    
    private lazy var profileImageView: UIImageView = {
        var imageView = UIImageView()
        return imageView
    }()
    
    private lazy var nickNameLabel: UILabel = {
        var label = UILabel()
        return label
    }()
    
    private lazy var contentTextView: UITextView = {
        var textView = UITextView()
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.backgroundColor = .blue
        textView.layer.masksToBounds = true
        textView.font = UIFont.systemFont(ofSize: 14)
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
            make.width.height.equalTo(45)
        }
        
        nickNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalTo(profileImageView.snp.right).offset(5)
        }
        
        contentTextView.snp.makeConstraints { make in
            make.top.equalTo(nickNameLabel.snp.bottom).offset(5)
            make.left.equalTo(profileImageView.snp.right).offset(5)
            make.right.lessThanOrEqualToSuperview().offset(-80)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.bottom.equalTo(contentTextView.snp.bottom)
            make.left.equalTo(contentTextView.snp.right).offset(3)
        }
    }
    
    func setData(model: ChatModel){
        self.timeLabel.text = model.date.convertDateToTime()
        self.contentTextView.text = model.message
        self.nickNameLabel.text = model.nickName
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentTextView.layer.cornerRadius = min(contentTextView.bounds.height, contentTextView.bounds.width) * 0.1
    }
    
    
}
