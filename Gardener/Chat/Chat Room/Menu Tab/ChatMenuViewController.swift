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
import FirebaseAuth

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
    
    private lazy var bottomSafeAreaView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        return view
    }()
    
    private lazy var exitButton: UIButton = {
        let button = UIButton()
        button.tintColor = .lightGray
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(systemName: "rectangle.portrait.and.arrow.right")
        configuration.preferredSymbolConfigurationForImage = .init(pointSize: 13)
        configuration.imagePlacement = .top
        configuration.imagePadding = 10
        button.configuration = configuration
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        initChatMemberTableView()
        addExitButtonAction()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    init(chatRoomModel: Observable<ChatRoomModel>, vc: UIViewController){
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
        self.view.addSubview(bottomSafeAreaView)
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(bottomSafeAreaView.snp.top)
        }
        
        // TODO: size refactor
        chatRoomViewModel.getMembersCount()
            .bind{ count in
                self.chatMenuView.snp.makeConstraints { make in
                    make.edges.equalToSuperview()
                    make.width.equalToSuperview()
                    make.height.equalTo(225 + count * 60)
                }
            }.disposed(by: disposeBag)
        
        bottomSafeAreaView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-50)
        }
        bottomSafeAreaView.addSubview(exitButton)
        
        exitButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(5)
            make.width.height.equalTo(45)
        }
    }
    
    func addExitButtonAction(){
        exitButton.rx
            .tap
            .bind{ _ in
                self.exitButtonAction()
            }.disposed(by: self.disposeBag)
    }
    
    
    func exitButtonAction(){
        showPopUp(title: "정말 채팅방에서 나가시겠습니까?", confirmButtonTitle: "나가기") { [weak self] in
            guard let self = self, let uid = Auth.auth().currentUser?.uid else { return }
         
            Observable.zip(self.chatRoomViewModel.isAmMaster(uid: uid), self.chatRoomViewModel.isAlone(), self.chatRoomViewModel.getChatRoomId())
                .bind{ master, alone, chatRoomId in
                    let userAccess = FirebaseFirestoreManager.shared.userExitedChatRoom(uid: uid, chatRoomId: chatRoomId)
                    let chatAccess = FirebaseFirestoreManager.shared.exitChatRoom(roomId: chatRoomId, uid: uid)
                    let checkObservables = [userAccess,chatAccess]
                    
                    if master, alone{
                        Observable.zip(checkObservables)
                            .bind{ _ in
                                self.dismiss(animated: false)
                            }.disposed(by: self.disposeBag)
     
                    }else if master{
                        self.dismiss(animated: false)
                        self.showPopUp(title: "관리자는 채팅방에 남겨진 인원들을 두고 떠날 수 없어요!") {}
                    }else{
                        Observable.zip(checkObservables)
                            .bind{ _ in
                                self.dismiss(animated: false)
                            }.disposed(by: self.disposeBag)
                    }
                }.disposed(by: self.disposeBag)
        }
    }
    
    
    func setData(model: Observable<ChatRoomModel>){
        chatMenuView.setData(model: model)
    }
    
    private func initChatMemberTableView(){
        self.chatMenuView.chatMemberTableView.register(ChatMemberTableViewCell.self, forCellReuseIdentifier: "chatMemberCell")
        chatMenuView.chatMemberTableView.rowHeight = 60
        
        chatRoomViewModel.chatMembers
            .bind(to: self.chatMenuView.chatMemberTableView.rx.items(cellIdentifier: "chatMemberCell", cellType: ChatMemberTableViewCell.self)){ index, model, cell in
                cell.setData(model: model)
            }.disposed(by: disposeBag)
        
        self.chatMenuView.chatMemberTableView.rx
            .itemSelected
            .bind{ indexPath in
                self.showProfileHalfView(index: indexPath.row)
            }.disposed(by: disposeBag)
    }
    
    
    private func showProfileHalfView(index: Int){
        let memberModel = self.chatRoomViewModel.getMember(index: index)
        guard let uid = memberModel.uid else {
            print("ChatMemberTableViewCell showProfileHalfView not exist model.uid")
            return
        }
    
        let vc = ProfileViewController(uid: uid)
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: false)
    }
}
