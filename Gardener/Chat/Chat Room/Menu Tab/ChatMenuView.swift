//
//  ChatMenuView.swift
//  Gardener
//
//  Created by 유현진 on 2/28/24.
//

import UIKit
import SnapKit

class ChatMenuView: UIView {
    
    private lazy var thumnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var chatTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        return label
    }()
    
    private lazy var chatSubTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        return label
    }()
    
    private lazy var createdDateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        return label
    }()
    
    private lazy var memberCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        return label
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
        
        self.addSubview(thumnailImageView)
        self.addSubview(chatTitleLabel)
        self.addSubview(chatSubTitleLabel)
        self.addSubview(memberCountLabel)
        self.addSubview(createdDateLabel)
        
        thumnailImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(150)
        }
        
        chatSubTitleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(thumnailImageView.snp.bottom).offset(-10)
            make.left.equalTo(thumnailImageView.snp.left).offset(10)
        }
        
        chatTitleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(chatSubTitleLabel.snp.top).offset(-10)
            make.left.equalTo(chatSubTitleLabel.snp.left)
        }
        
        memberCountLabel.snp.makeConstraints { make in
            make.top.equalTo(thumnailImageView.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(10)
        }
        
        createdDateLabel.snp.makeConstraints { make in
            make.top.equalTo(memberCountLabel.snp.bottom).offset(5)
            make.left.equalToSuperview().offset(10)
        }
    }
    
    func setData(model: ChatRoomModel){
        thumnailImageView.setImageView(url: model.thumbnailURL)
        chatTitleLabel.text = model.title
        chatSubTitleLabel.text = model.subTitle
        memberCountLabel.text = "\(model.members.count)명"
        createdDateLabel.text = model.date.convertDate()
    }
    
    func getContentHeight() -> CGFloat{
        return thumnailImageView.frame.size.height + 10 + memberCountLabel.intrinsicContentSize.height
        + 5 + createdDateLabel.intrinsicContentSize.height
    }
}
