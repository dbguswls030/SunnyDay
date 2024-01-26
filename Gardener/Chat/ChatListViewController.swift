//
//  ShopViewController.swift
//  Gardener
//
//  Created by 유현진 on 2023/03/28.
//

import UIKit
import SnapKit
import RxSwift
import ReactorKit
import RxCocoa

class ChatListViewController: UIViewController {

    var disposeBag = DisposeBag()
    
    var chatViewModel = ChatViewModel()
    
    private lazy var chatListView: ChatListView = {
        return ChatListView()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        initUI()
        initNavigationBar()
        setChatTableView()
    }
    
    private func initUI(){
        self.view.addSubview(chatListView)
        chatListView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            make.left.right.equalToSuperview()
        }
    }
    
    private func initNavigationBar(){
        self.title = "채팅 목록"
    }
    
    private func setChatTableView(){
        chatListView.chatTableView.register(ChatTableViewCell.self, forCellReuseIdentifier: "chatCell")
        chatListView.chatTableView.rowHeight = 100
        chatViewModel.getChatList()
            .bind(to: chatListView.chatTableView.rx.items(cellIdentifier: "chatCell", cellType: ChatTableViewCell.self)) { index, item, cell in
                cell.setChatTitle(chatTitle: item.title)
            }
            .disposed(by: disposeBag)
    }
}
