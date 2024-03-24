//
//  ChatMenuView.swift
//  Gardener
//
//  Created by 유현진 on 2/28/24.
//

import UIKit
import SnapKit
import RxSwift

class ChatMenuView: UIView {
    
    var disposeBag = DisposeBag()
    
    private lazy var thumnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var chatInfoButton: UIButton = {
        let button = UIButton()
        button.tintColor = .lightGray
        button.setImage(UIImage(systemName: "arrowshape.right.circle.fill"), for: .normal)
        return button
    }()
    
    private lazy var chatMemberListLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "참여 인원"
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    lazy var chatMemberTableView: UITableView = {
        let tableView = UITableView()
        tableView.isScrollEnabled = false
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        return tableView
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
        self.addSubview(chatInfoButton)
        self.addSubview(chatMemberListLabel)
        self.addSubview(chatMemberTableView)
        
        
        thumnailImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
//            make.height.lessThanOrEqualTo(140)
//            make.width.equalTo(thumnailImageView.snp.height)
            make.width.height.equalTo(140)
        }
        
        chatInfoButton.snp.makeConstraints { make in
            make.bottom.equalTo(thumnailImageView.snp.bottom)
            make.right.equalTo(thumnailImageView.snp.right)
            make.width.height.equalTo(35)
        }
        
        chatMemberListLabel.snp.makeConstraints { make in
            make.top.equalTo(thumnailImageView.snp.bottom).offset(30)
            make.left.equalToSuperview().offset(10)
            make.height.equalTo(20)
        }
        
        chatMemberTableView.snp.makeConstraints { make in
            make.top.equalTo(chatMemberListLabel.snp.bottom).offset(5)
            make.left.right.equalToSuperview()
            make.width.equalTo(self.snp.width)
            make.bottom.equalToSuperview()
        }

        
    }
    
    func setData(model: Observable<ChatRoomModel>){
        model.bind{ chatRoom in
            self.thumnailImageView.setImageView(url: chatRoom.thumbnailURL)
            self.chatMemberListLabel.text = "참여 인원 \(chatRoom.members.count)"
        }.disposed(by: disposeBag)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.thumnailImageView.layer.cornerRadius = self.thumnailImageView.frame.size.height * 0.1
    }
}
