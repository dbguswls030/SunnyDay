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
    
    var chatViewModel = ChatListViewModel()
    
    private lazy var chatListView: ChatListView = {
        return ChatListView()
    }()
    
    private lazy var creatChatRoomItem: UIBarButtonItem = {
        return UIBarButtonItem(title: nil, image: UIImage(systemName: "plus.bubble"), target: self, action: #selector(createChatRoom))
    }()
    
    private lazy var searchChatRoomItem: UIBarButtonItem = {
        return UIBarButtonItem(title: nil, image: UIImage(systemName: "magnifyingglass"), target: self, action: nil)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        initUI()
        setChatTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initNavigationBar()
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
        self.title = "채팅"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 28, weight: .bold)]
        
        self.navigationItem.rightBarButtonItems = [creatChatRoomItem, searchChatRoomItem]
        self.navigationItem.rightBarButtonItems?.forEach({ buttonItem in
            buttonItem.tintColor = .black
        })
        
    }
    private func c(){
        self.navigationItem.rightBarButtonItems![1].rx
            .tap
            .bind{
                
            }.disposed(by: disposeBag)
    }
    @objc private func createChatRoom(){
        let vc = CreateChatViewController()
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true)
    }
    
    
    private func setChatTableView(){
        chatListView.participatedChatTableView.register(ChatTableViewCell.self, forCellReuseIdentifier: "chatCell")
        chatListView.participatedChatTableView.rowHeight = 90
        
        chatViewModel.chatRooms
            .bind(to: chatListView.participatedChatTableView.rx.items(cellIdentifier: "chatCell", cellType: ChatTableViewCell.self)) { index, item, cell in
                cell.setChatTitle(chatTitle: item.title)
            }
            .disposed(by: disposeBag)
        
        
        chatListView.participatedChatTableView.rx.modelSelected(ChatRoomModel.self)
            .subscribe(onNext: { chatModel in
                let vc = ChatViewController()
                vc.setChatTitle(chatTitle: chatModel.title)
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.navigationBar.prefersLargeTitles = false
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
        
        chatListView.participatedChatTableView.rx.itemSelected
            .bind(onNext: { indexPath in
                self.chatListView.participatedChatTableView.deselectRow(at: indexPath, animated: true)
            })
            .disposed(by: disposeBag)
    }

}
