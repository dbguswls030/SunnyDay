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
    
    private lazy var chatTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 19, weight: .semibold)
        label.textAlignment = .center
        label.text = " "
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var chatInfoButton: UIButton = {
        let button = UIButton()
        return button
    }()
    
    private lazy var chatCreateAtLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        label.text = "생성일 "
        return label
    }()
    
    private lazy var chatMemberCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        label.text = "인원 "
        return label
    }()
    
    private lazy var chatLikeCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        label.text = "좋아요 0개"
        return label
    }()
    
    private lazy var chatInfoBreakLine: BreakLine = {
        return BreakLine()
    }()
    
    private lazy var chatMemberListLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "참여 인원"
        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        return label
    }()
    
    lazy var chatMemberTableView: UITableView = {
        let tableView = UITableView()
        tableView.isScrollEnabled = false
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.separatorStyle = .none
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
        self.addSubview(chatTitleLabel)
        self.addSubview(chatCreateAtLabel)
        self.addSubview(chatLikeCountLabel)
        self.addSubview(chatMemberCountLabel)
    
        self.addSubview(chatInfoBreakLine)
        
        self.addSubview(chatInfoButton)
        self.addSubview(chatMemberListLabel)
        self.addSubview(chatMemberTableView)
        
        
        chatTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
        }
        
        chatInfoButton.snp.makeConstraints { make in
            make.top.equalTo(chatTitleLabel.snp.top)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(chatInfoBreakLine.snp.top)
        }
        
        chatCreateAtLabel.snp.makeConstraints { make in
            make.top.equalTo(chatTitleLabel.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(10)
        }
        
        chatMemberCountLabel.snp.makeConstraints { make in
            make.top.equalTo(chatCreateAtLabel.snp.bottom).offset(5)
            make.left.equalToSuperview().offset(10)
        }
        
        chatLikeCountLabel.snp.makeConstraints { make in
            make.top.equalTo(chatCreateAtLabel.snp.bottom).offset(5)
            make.left.equalTo(chatMemberCountLabel.snp.right).offset(10)
        }
        
        chatInfoBreakLine.snp.makeConstraints { make in
            make.top.equalTo(chatMemberCountLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(0.4)
        }

        
        chatMemberListLabel.snp.makeConstraints { make in
            make.top.equalTo(chatInfoBreakLine.snp.bottom).offset(30)
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
        model.bind{ chatRoomModel in
            self.chatTitleLabel.text = chatRoomModel.title
            self.chatMemberCountLabel.text = "인원 \(chatRoomModel.members.count)명"
            self.chatCreateAtLabel.text = "생성일 \(chatRoomModel.date.convertDate())"
            self.chatMemberListLabel.text = "참여 인원 \(chatRoomModel.members.count)"
            // TODO: 좋아요 갯수
        }.disposed(by: disposeBag)
    }
    
    func addChatInfoButtonAction(){
        chatInfoButton.rx
            .tap
            .bind{ _ in
                // TODO: 채팅방 정보 보기
            }.disposed(by: self.disposeBag)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
