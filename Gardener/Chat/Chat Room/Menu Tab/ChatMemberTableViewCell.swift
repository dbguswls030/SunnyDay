//
//  ChatMemberTableViewCell.swift
//  Gardener
//
//  Created by 유현진 on 3/1/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class ChatMemberTableViewCell: UITableViewCell {

    var disposeBag = DisposeBag()
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.layer.borderWidth = 0.2
        return imageView
    }()
    
    private lazy var nickNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func prepareForReuse() {
        profileImageView.image = nil
        nickNameLabel.text = " "
    }
    
    func initUI(){
        self.backgroundColor = .systemBackground
        let clearView = UIView()
        clearView.backgroundColor = .clear
        self.selectedBackgroundView = clearView
        self.addSubview(profileImageView)
        self.addSubview(nickNameLabel)
        
        profileImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(10)
            make.width.height.equalTo(40)
        }
        
        nickNameLabel.snp.makeConstraints { make in
            make.left.equalTo(profileImageView.snp.right).offset(10)
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
        }
    }
    
    func setData(model: ChatMemberModel){
        guard let uid = model.uid else {
            print("ChatMemberTableViewCell setData exist model.uid")
            return
        }
        FirebaseFirestoreManager.shared.getUserInfoWithRx(uid: uid)
            .bind{ userModel in
                self.profileImageView.setImageView(url:  userModel.profileImageURL)
                self.nickNameLabel.text = userModel.nickName
            }.disposed(by: disposeBag)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        profileImageView.layer.cornerRadius = profileImageView.frame.size.height * 0.25
    }
}
