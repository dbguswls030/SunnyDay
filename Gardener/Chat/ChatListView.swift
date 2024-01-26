//
//  ChatListView.swift
//  Gardener
//
//  Created by 유현진 on 1/26/24.
//

import UIKit
import SnapKit

class ChatListView: UIView {
    
    lazy var chatTableView: UITableView = {
        var tableView = UITableView()
        return tableView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initUI(){
        addSubview(chatTableView)
        chatTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
