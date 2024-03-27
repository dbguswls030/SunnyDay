//
//  SearchChatRoomTableViewCell.swift
//  Gardener
//
//  Created by 유현진 on 2/19/24.
//

import UIKit
import SnapKit

class SearchChatRoomTableViewCell: UITableViewCell {

    private lazy var thumbnailImageView: UIImageView = {
        var imageView = UIImageView()
        return imageView
    }()
    
    private lazy var chatTitleLabel: UILabel = {
        var label = UILabel()
        label.textColor = .black
        return label
    }()
    
    private lazy var chatSubTitleLabel: UILabel = {
        var label = UILabel()
        label.textColor = .black
        return label
    }()
    
    private lazy var memberCountLabel: UILabel = {
        var label = UILabel()
        label.textColor = .black
        return label
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initUI()
    }
    
    override func prepareForReuse() {
        thumbnailImageView.image = nil
        chatTitleLabel.text = ""
        chatSubTitleLabel.text = ""
        memberCountLabel.text = ""
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initUI(){
        self.backgroundColor = .systemBackground
        
        self.addSubview(thumbnailImageView)
        self.addSubview(chatTitleLabel)
        self.addSubview(chatSubTitleLabel)
        self.addSubview(memberCountLabel)
        
        thumbnailImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(10)
            make.width.height.equalTo(60)
        }
        
        memberCountLabel.snp.makeConstraints { make in
            make.top.equalTo(thumbnailImageView.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(15)
        }
        
        chatTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(memberCountLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        chatSubTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.equalTo(thumbnailImageView.snp.right).offset(15)
            make.bottom.equalTo(memberCountLabel.snp.bottom)
        }
    }
    
    func setData(model: ChatRoomModel){
        self.chatTitleLabel.text = model.title
        self.chatSubTitleLabel.text = model.subTitle
        self.thumbnailImageView.setImageView(url: model.thumbnailURL)
        self.memberCountLabel.text = "\(model.memberCount)"
    }
}
