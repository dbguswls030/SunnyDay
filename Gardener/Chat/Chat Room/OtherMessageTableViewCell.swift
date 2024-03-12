//
//  OtherMessageTableViewCell.swift
//  Gardener
//
//  Created by 유현진 on 3/8/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class OtherMessageTableViewCell: UITableViewCell {

    static let identifier = "OtherMessageCell"
    
    var disposeBag = DisposeBag()
    
    var menuInteraction: UIContextMenuInteraction!
    
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
    
    lazy var messageLabel: MessageLabel = {
        var label = MessageLabel()
        label.backgroundColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 14)
        label.clipsToBounds = true
        label.numberOfLines = 0
        label.isUserInteractionEnabled = true
        label.layer.cornerRadius = 5
        return label
    }()
    
    private lazy var timeLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10, weight: .light)
        label.textColor = .systemGray
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        nickNameLabel.text = " "
        profileImageView.image = nil
        messageLabel.text = " "
        timeLabel.text = " "
    }
    
    func addMenuInteraction(vc: UIContextMenuInteractionDelegate){
        menuInteraction = .init(delegate: vc)
        messageLabel.addInteraction(menuInteraction)
    }
    
    private func initUI(){
        backgroundColor = .clear
        let clearView = UIView()
        clearView.backgroundColor = .clear
        self.selectedBackgroundView = clearView
        self.contentView.addSubview(profileImageView)
        self.contentView.addSubview(nickNameLabel)
        self.contentView.addSubview(messageLabel)
        self.contentView.addSubview(timeLabel)
        
        profileImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.left.equalToSuperview().offset(8)
            make.width.height.equalTo(35)
        }
        
        nickNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.left.equalTo(profileImageView.snp.right).offset(7)
            make.height.equalTo(14)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(nickNameLabel.snp.bottom).offset(5)
            make.left.equalTo(profileImageView.snp.right).offset(7)
            make.right.lessThanOrEqualToSuperview().offset(-80).priority(.high)
            make.bottom.equalToSuperview().offset(-5)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.bottom.equalTo(messageLabel.snp.bottom)
            make.left.equalTo(messageLabel.snp.right).offset(3)
        }
    }
    
    func setData(model: ChatMessageModel){
        self.timeLabel.text = model.date.convertDateToCurrentTime()
        self.messageLabel.text = model.message
        self.messageLabel.sizeToFit()
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
        profileImageView.layer.cornerRadius = profileImageView.frame.size.height * 0.25
    }
}
