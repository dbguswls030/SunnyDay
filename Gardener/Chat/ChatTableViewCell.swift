//
//  ChatTableViewCell.swift
//  Gardener
//
//  Created by 유현진 on 1/26/24.
//

import UIKit
import SnapKit

class ChatTableViewCell: UITableViewCell {
    
    private lazy var chatThumbnailImageView: UIImageView = {
        var imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 0.2
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        return imageView
    }()
    
    private lazy var chatTitleLabel: UILabel = {
        var label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 17, weight: .medium)
        return label
    }()
    
    private lazy var chatSubTitleLabel: UILabel = {
        var label = UILabel()
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 12, weight: .regular)
        return label
    }()
    
    private lazy var memberCountLabel: UILabel = {
        var label = UILabel()
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        return label
    }()
    
    private lazy var updateDateLabel: UILabel = {
        var label = UILabel()
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 10, weight: .light)
        return label
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        chatTitleLabel.text = ""
        chatSubTitleLabel.text = ""
        chatThumbnailImageView.image = nil
        updateDateLabel.text = ""
        memberCountLabel.text = ""
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    private func initUI(){
        backgroundColor = .systemBackground
        self.addSubview(chatThumbnailImageView)
        self.addSubview(chatTitleLabel)
        self.addSubview(chatSubTitleLabel)
        self.addSubview(memberCountLabel)
        self.addSubview(updateDateLabel)
        
        chatThumbnailImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.bottom.equalToSuperview().offset(-14)
            make.left.equalToSuperview().offset(15)
            make.width.equalTo(chatThumbnailImageView.snp.height)
        }
        
        chatTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(chatThumbnailImageView.snp.top).offset(4)
            make.left.equalTo(chatThumbnailImageView.snp.right).offset(12)
            make.right.greaterThanOrEqualTo(updateDateLabel.snp.left).offset(-15)
        }
        
        chatSubTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(chatTitleLabel.snp.left)
            make.top.equalTo(chatTitleLabel.snp.bottom).offset(6)
            make.right.greaterThanOrEqualTo(updateDateLabel.snp.left).offset(-15)
        }
        
        updateDateLabel.snp.makeConstraints { make in
            make.centerY.equalTo(chatTitleLabel.snp.centerY)
            make.right.equalToSuperview().offset(-10)
            make.width.equalTo(50)
        }
        
        memberCountLabel.snp.makeConstraints { make in
            make.top.equalTo(chatSubTitleLabel.snp.top)
            make.right.equalToSuperview().offset(-15)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        chatThumbnailImageView.layer.cornerRadius = chatThumbnailImageView.frame.size.height * 0.25
    }
    
    func setData(model: ChatRoomModel){
        self.chatTitleLabel.text = model.title
        self.chatSubTitleLabel.text = model.subTitle
        self.chatThumbnailImageView.setImageView(url: model.thumbnailURL)
        self.updateDateLabel.text = model.date.convertDateToCurrentTime()
        self.memberCountLabel.text = "\(model.memberCount)"
    }
}
