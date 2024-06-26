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
    var chatRoomId: String
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
    
    private lazy var settingButton: UIButton = {
        let button = UIButton()
        button.tintColor = .lightGray
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(systemName: "gearshape")
        configuration.preferredSymbolConfigurationForImage = .init(pointSize: 14)
        configuration.imagePlacement = .top
        configuration.imagePadding = 10
        button.configuration = configuration
        button.isHidden = true
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        setData()
        initChatMemberTableView()
        chatMenuUpdateHeight()
        addExitButtonAction()
        initSettingButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        disposeBag = DisposeBag()
    }
    
    deinit{
        print("sideMenu deinit")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    init(chatRoomId: String){
        chatRoomViewModel = ChatMenuViewModel(chatRoomId: chatRoomId)
        self.chatRoomId = chatRoomId
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
            make.width.equalToSuperview()
            make.bottom.equalTo(bottomSafeAreaView.snp.top)
        }
        
        chatMenuView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(160)
        }
        
        bottomSafeAreaView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-50)
        }
        
        bottomSafeAreaView.addSubview(exitButton)
        bottomSafeAreaView.addSubview(settingButton)
        
        exitButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(5)
            make.width.height.equalTo(45)
        }
        
        settingButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.right.equalToSuperview().offset(-5)
            make.width.height.equalTo(45)
        }
    }
    
    func chatMenuUpdateHeight(){
        // TODO: Size Refactor
        chatRoomViewModel.getMembersCount()
            .filter{ $0 > 0}
            .observe(on: MainScheduler.instance)
            .bind{ [weak self] count in
                self?.chatMenuView.snp.updateConstraints { make in
                    make.height.equalTo(160 + (count * 50))
                }
            }.disposed(by: disposeBag)
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
         
            Observable.zip(self.chatRoomViewModel.isAmNotCommon(uid: uid), self.chatRoomViewModel.isAlone(), self.chatRoomViewModel.getChatRoomId())
                .bind{ isMaster, isAlone, chatRoomId in
                    let userAccess = FirebaseFirestoreManager.shared.userExitedChatRoom(uid: uid, chatRoomId: chatRoomId)
                    let chatAccess = FirebaseFirestoreManager.shared.exitChatRoom(roomId: chatRoomId, uid: uid)
                    let checkObservables = [userAccess,chatAccess]
                    
                    if isMaster, isAlone{
                        Observable.zip(checkObservables)
                            .bind{ _ in
                                self.dismiss(animated: false)
                            }.disposed(by: self.disposeBag)
                    }else if isMaster{
                        self.dismiss(animated: false)
                        self.showPopUp(title: "관리자는 채팅방에 남겨진 인원들을 두고 떠날 수 없어요!") {}
                    }else{
                        Observable.zip(checkObservables)
                            .bind{ _ in
                                self.dismiss(animated: false)
                            }.disposed(by: self.disposeBag)
                    }
                    self.dismiss(animated: false)
                }.disposed(by: self.disposeBag)
        }
    }
    
    func initSettingButton(){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        self.chatRoomViewModel.isAmMaster(uid: uid)
            .bind{ [weak self] isMaster in
                guard let self = self else { return }
                if isMaster{
                    self.settingButton.isHidden = false
                    self.settingButtonAction()
                }
            }.disposed(by: self.disposeBag)
    }
    
    func settingButtonAction(){
        self.settingButton.rx
            .tap
            .bind{ _ in
                self.chatRoomViewModel.chatRoomModel
                    .bind{ [weak self] in
                        guard let self = self else { return }
                        let vc = EditChatRoomViewController(chatRoomModel: $0)
                        vc.modalPresentationStyle = .overFullScreen
                        self.present(vc, animated: true)
                    }.disposed(by: self.disposeBag)
            }.disposed(by: self.disposeBag)
    }
    
    
    func setData(){
        self.chatRoomViewModel.chatRoomModel
            .bind{ [weak self] model in
                self?.chatMenuView.setData(model: model)
            }.disposed(by: self.disposeBag)
        
    }
    
    private func initChatMemberTableView(){
        self.chatMenuView.chatMemberTableView.register(ChatMemberTableViewCell.self, forCellReuseIdentifier: "chatMemberCell")
        chatMenuView.chatMemberTableView.rowHeight = 50

        chatRoomViewModel.chatMembers
            .bind(to: self.chatMenuView.chatMemberTableView.rx.items(cellIdentifier: "chatMemberCell", cellType: ChatMemberTableViewCell.self)){ index, model, cell in
                cell.setData(model: model)
            }.disposed(by: disposeBag)
        
        
        self.chatMenuView.chatMemberTableView.rx
            .itemSelected
            .bind{ [weak self] indexPath in
                self?.showProfileHalfView(index: indexPath.row)
            }.disposed(by: disposeBag)
    }

    private func showProfileHalfView(index: Int){
        let memberModel = self.chatRoomViewModel.getMember(index: index)
        
        guard let uid = memberModel.uid else {
            print("ChatMemberTableViewCell showProfileHalfView not exist model.uid")
            return
        }
        
        if uid == Auth.auth().currentUser!.uid{ return } // 나 자신은 하프뷰 X
        let vc = ProfileViewController(profileUid: uid, chatRoomId: self.chatRoomId, myUid: Auth.auth().currentUser!.uid)
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: false)
    }
}
