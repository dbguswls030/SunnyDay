//
//  SearchChatView.swift
//  Gardener
//
//  Created by 유현진 on 2/19/24.
//

import UIKit
import SnapKit

class SearchChatView: UIView {

    lazy var searchChatListTableView: UITableView = {
        var tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.alwaysBounceVertical = true
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
        self.addSubview(searchChatListTableView)
        
        searchChatListTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
}
