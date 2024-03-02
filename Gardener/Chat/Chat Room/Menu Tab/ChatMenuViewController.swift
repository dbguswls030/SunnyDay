//
//  ChatMenuViewController.swift
//  Gardener
//
//  Created by 유현진 on 2/28/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class ChatMenuViewController: UIViewController {
    
    var disposeBag = DisposeBag()
    var chatRoomViewModel: ChatMenuViewModel
    
    private lazy var chatMenuView: ChatMenuView = {
        return ChatMenuView()
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        initChatMemberTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    init(chatRoomModel: Observable<ChatRoomModel>){
        chatRoomViewModel = ChatMenuViewModel(chatRoomModel: chatRoomModel)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initUI(){
        self.view.backgroundColor = .systemBackground
        self.view.addSubview(scrollView)
        self.scrollView.addSubview(chatMenuView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            
        }
        chatRoomViewModel.getMembersCount()
            .bind{ count in
                self.chatMenuView.snp.makeConstraints { make in
                    make.edges.equalToSuperview()
                    make.width.equalToSuperview()
                    make.height.equalTo(225 + count * 60)
                }
            }.disposed(by: disposeBag)
        
        
    }
    
    func setData(model: Observable<ChatRoomModel>){
        chatMenuView.setData(model: model)
    }
    
    func initChatMemberTableView(){
        self.chatMenuView.chatMemberTableView.register(ChatMemberTableViewCell.self, forCellReuseIdentifier: "chatMemberCell")
        chatMenuView.chatMemberTableView.rowHeight = 60
        
        chatRoomViewModel.getMembers()
            .bind(to: self.chatMenuView.chatMemberTableView.rx.items(cellIdentifier: "chatMemberCell", cellType: ChatMemberTableViewCell.self)){ index, model, cell in
                cell.setData(model: model)
            }.disposed(by: disposeBag)
    }
}
