//
//  ChatListTopView.swift
//  Gardener
//
//  Created by 유현진 on 2/17/24.
//

import UIKit
import SnapKit

class ChatListTopView: UIView {

    private lazy var titleLable: UILabel = {
        var label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .black
        label.text = "채팅"
        return label
    }()
    
    lazy var createChatRoomButton: UIButton = {
        var button = UIButton()
        button.setImage(UIImage(systemName: "plus.bubble", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20)), for: .normal)
        button.tintColor = .black
        return button
    }()
    
    lazy var searchChatRoomButton: UIButton = {
        var button = UIButton()
        button.setImage(UIImage(systemName: "magnifyingglass", withConfiguration: UIImage.SymbolConfiguration(pointSize: 19)), for: .normal)
        button.tintColor = .black
        return button
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
        
        self.addSubview(titleLable)
        self.addSubview(createChatRoomButton)
        self.addSubview(searchChatRoomButton)
        
        titleLable.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.top.bottom.equalToSuperview()
        }
        
        createChatRoomButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.width.equalTo(createChatRoomButton.snp.height)
            make.right.equalToSuperview().offset(-5)
        }
        
        searchChatRoomButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.width.equalTo(createChatRoomButton.snp.height)
            make.right.equalTo(createChatRoomButton.snp.left)
        }
    }
    
}
