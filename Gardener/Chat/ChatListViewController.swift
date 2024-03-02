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
    
    private lazy var toolView: ChatListTopView = {
        return ChatListTopView()
    }()
    
    private lazy var chatListView: ChatListView = {
        return ChatListView()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        setChatTableView()
        initToolButtonItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    private func initUI(){
        self.view.backgroundColor = .systemBackground
        
        self.view.addSubview(toolView)
        self.view.addSubview(chatListView)
        
        toolView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
        chatListView.snp.makeConstraints { make in
            make.top.equalTo(toolView.snp.bottom)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            make.left.right.equalToSuperview()
        }
    }
    
    private func searchChatRoomButtonAction(){
        self.toolView.searchChatRoomButton.rx
            .tap
            .bind{
                let vc = SearchChatRoomViewController()
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }.disposed(by: disposeBag)
    }
    
    private func createChatRoomButtonAction(){
        self.toolView.createChatRoomButton.rx
            .tap
            .bind{
                let vc = CreateChatViewController()
                vc.modalPresentationStyle = .overFullScreen
                self.present(vc, animated: true)
            }.disposed(by: disposeBag)
    }
    
    private func initToolButtonItems(){
        searchChatRoomButtonAction()
        createChatRoomButtonAction()
        
    }
    
    private func setChatTableView(){
        chatListView.participatedChatTableView.register(ChatTableViewCell.self, forCellReuseIdentifier: "chatCell")
        chatListView.participatedChatTableView.rowHeight = 80
        
        chatViewModel.chatRooms
            .bind(to: chatListView.participatedChatTableView.rx.items(cellIdentifier: "chatCell", cellType: ChatTableViewCell.self)) { index, item, cell in
                cell.setData(model: item)
            }
            .disposed(by: disposeBag)
        
        
        chatListView.participatedChatTableView.rx.modelSelected(ChatRoomModel.self)
            .subscribe(onNext: { chatRoomModel in
                let vc = ChatViewController(chatRoomId: chatRoomModel.roomId)
                vc.hidesBottomBarWhenPushed = true
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
