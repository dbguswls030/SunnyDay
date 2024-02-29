//
//  ChatViewController.swift
//  Gardener
//
//  Created by 유현진 on 1/26/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import FirebaseAuth
import SideMenu

class ChatViewController: UIViewController{
    
    // TODO: 임시 ViewModel 만들어서 테스트해보기
    var chatViewModel: ChatViewModel
    
    var disposeBag = DisposeBag()
    
    private lazy var inputBarView: InputBarView = {
        return InputBarView()
    }()
    
    private lazy var chatCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    private lazy var menuButton: UIButton = {
        let button = UIButton()
        button.tintColor = .black
        button.setImage(UIImage(systemName: "line.horizontal.3",withConfiguration: UIImage.SymbolConfiguration(pointSize: 22)), for: .normal)
        return button
    }()

    init(chatRoomModel: ChatRoomModel) {
        self.chatViewModel = ChatViewModel(chatRoomModel: chatRoomModel)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTouchUpBackground()
        initUI()
        setChatTitle()
        setSendButton()
        setInputBarView()
        initCollectionView()
        initNavigationItem()
        menuButtonAction()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.backgroundColor = .clear
        self.navigationController?.navigationBar.alpha = 0.9
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.navigationBar.alpha = 1
        self.navigationController?.navigationBar.backgroundColor = .systemBackground
    }
    
    private func initNavigationItem(){
        self.navigationItem.setRightBarButton(UIBarButtonItem(customView: menuButton), animated: false)
    }
    
    private func menuButtonAction(){
        self.menuButton.rx
            .tap
            .bind{
                let vc = ChatMenuViewController()
                vc.setData(model: self.chatViewModel.chatRoomModel)
                let menuVC = SideMenuNavigationController(rootViewController: vc)
                
                menuVC.presentationStyle = .menuSlideIn
                menuVC.menuWidth = self.view.frame.width * 0.8
                menuVC.sideMenuDelegate = self
                menuVC.statusBarEndAlpha = 0.0
                self.present(menuVC, animated: true)
                
            }.disposed(by: disposeBag)
    }

    private func initCollectionView(){
        chatCollectionView.delegate = self
        chatCollectionView.dataSource = self
        let topInset = navigationController?.navigationBar.frame.height ?? 0
//        let topInset = navigationController?.navigationBar.isTranslucent == true ? 0 : navigationController?.navigationBar.frame.height ?? 0
        chatCollectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 5, right: 0)
        
        chatCollectionView.register(ChatMyCollectionViewCell.self, forCellWithReuseIdentifier: ChatMyCollectionViewCell.identifier)
        chatCollectionView.register(ChatOtherCollectionViewCell.self, forCellWithReuseIdentifier: ChatOtherCollectionViewCell.identifier)
        
        chatViewModel.getFirstChatMessages()
            .bind {
                self.chatCollectionView.reloadData()
                DispatchQueue.main.async {
                    if self.chatCollectionView.contentSize.height > self.chatCollectionView.bounds.height{
                        let contentHeight = self.chatCollectionView.contentSize.height
                        let offsetY = max(0, contentHeight - self.chatCollectionView.bounds.size.height + 10)
                        self.chatCollectionView.setContentOffset(CGPoint(x: 0, y: offsetY), animated: false)
                    }
                    
                }
            }
            .disposed(by: disposeBag)
        
        chatViewModel.addListenerChatMessages()
            .skip(1)
            .bind{ messages ,newMessages in
                self.chatViewModel.messages.accept(messages+newMessages)
                let startIndex = self.chatCollectionView.numberOfItems(inSection: 0)
                let endIndex = startIndex + newMessages.count
                let indexPaths = (startIndex..<endIndex).map { IndexPath(item: $0, section: 0) }
                self.chatCollectionView.performBatchUpdates {
                    self.chatCollectionView.insertItems(at: indexPaths)
                } completion: { complete in
                    if complete{
                        DispatchQueue.main.async {
                            if self.chatCollectionView.contentSize.height > self.chatCollectionView.bounds.height{
                                let contentHeight = self.chatCollectionView.contentSize.height
                                let offsetY = max(0, contentHeight - self.chatCollectionView.bounds.size.height + 10)
                                self.chatCollectionView.setContentOffset(CGPoint(x: 0, y: offsetY), animated: false)
                            }
                        }
                    }
                }
            }.disposed(by: disposeBag)
    }

    private func initUI(){
        self.view.backgroundColor = .systemBackground
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationController?.navigationBar.topItem?.title = ""
        
        self.view.addSubview(chatCollectionView)
        self.view.addSubview(inputBarView)
        
        chatCollectionView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.bottom.equalTo(inputBarView.snp.top)
        }
        
        inputBarView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(self.view.keyboardLayoutGuide.snp.top)
        }
    }
    
    private func setChatTitle(){
        self.title = chatViewModel.getChatRoomTitle()
    }
    
    private func setSendButton(){
        // 텍스트의 유무에 따라 버튼 활성화
        inputBarView.inputTextView.rx.text
            .orEmpty
            .distinctUntilChanged()
            .bind{ text in
                if text.trimmingCharacters(in: .whitespaces).isEmpty {
                    self.inputBarView.sendButton.isEnabled = false
                }else{
                    self.inputBarView.sendButton.isEnabled = true
                }
            }.disposed(by: disposeBag)
        
        // TODO: 버튼 클릭 시
    }
    
    private func setInputBarView(){
        // 텍스트 입력 시 동적 높이 조절
        inputBarView.inputTextView.rx.text
            .orEmpty
            .distinctUntilChanged()
            .bind{ text in
                let size = CGSize(width: self.inputBarView.inputTextView.frame.width, height: .infinity)
                let estimatedSize = self.inputBarView.inputTextView.sizeThatFits(size)
                
                self.inputBarView.inputTextView.constraints.forEach { constraint in
                    if estimatedSize.height >= 120{
                        self.inputBarView.inputTextView.isScrollEnabled = true
                    }else{
                        self.inputBarView.inputTextView.sizeToFit()
                        self.inputBarView.inputTextView.isScrollEnabled = false
                        if constraint.firstAttribute == .height{
                            constraint.constant = estimatedSize.height
                        }
                    }
                }
            }.disposed(by: disposeBag)
        
        inputBarView.sendButton.rx
            .tap
            .map{
                let message = self.inputBarView.inputTextView.text ?? ""
                self.inputBarView.inputTextView.text = ""
                return ChatMessageModel(uid: Auth.auth().currentUser!.uid, message: message, date: Date())
            }.flatMap{ messageModel in
                FirebaseFirestoreManager.shared.sendChatMessage(chatRoom: self.chatViewModel.chatRoomModel, message: messageModel)
            }
            .bind{}
            .disposed(by: disposeBag)
    }
    
    private func configureCell(collectionView: UICollectionView, index: Int, model: ChatMessageModel) -> UICollectionViewCell{
        if model.uid == Auth.auth().currentUser!.uid{
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChatMyCollectionViewCell.identifier, for: IndexPath(item: index, section: 0)) as? ChatMyCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.setData(model: model)
            return cell
        }else{
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChatOtherCollectionViewCell.identifier, for: IndexPath(item: index, section: 0)) as? ChatOtherCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.setData(model: model)
            return cell
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension ChatViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        chatViewModel.messages.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let model = chatViewModel.getChatModel(at: indexPath.item) else {
            return UICollectionViewCell()
        }
        
        if model.uid == Auth.auth().currentUser!.uid{
            let cell = self.chatCollectionView.dequeueReusableCell(withReuseIdentifier: ChatMyCollectionViewCell.identifier, for: IndexPath(item: indexPath.item, section: 0)) as! ChatMyCollectionViewCell
            cell.setData(model: model)
            return cell
        }else{
            let cell = self.chatCollectionView.dequeueReusableCell(withReuseIdentifier: ChatOtherCollectionViewCell.identifier, for: IndexPath(item: indexPath.item, section: 0)) as! ChatOtherCollectionViewCell
            cell.setData(model: model)
            return cell
        }
    }
}

extension ChatViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if chatViewModel.getChatModel(at: indexPath.item)?.uid == Auth.auth().currentUser!.uid{
            let cell = self.configureCell(collectionView: collectionView, index: indexPath.item, model: chatViewModel.getChatModel(at: indexPath.item)!) as! ChatMyCollectionViewCell
            return CGSize(width: collectionView.bounds.size.width, height: cell.getTextViewHeight())
        }else{
            let cell = self.configureCell(collectionView: collectionView, index: indexPath.item, model: chatViewModel.getChatModel(at: indexPath.item)!) as! ChatOtherCollectionViewCell
            return CGSize(width: collectionView.bounds.size.width, height: cell.getCellHeight())
        }
    }
}


extension ChatViewController: SideMenuNavigationControllerDelegate{
    
    func sideMenuWillAppear(menu: SideMenuNavigationController, animated: Bool) {
        UIView.animate(withDuration: 0.35) {
            self.view.alpha = 0.6
            self.navigationController?.navigationBar.alpha = 0.6
            
        }
    }
    func sideMenuDidDisappear(menu: SideMenuNavigationController, animated: Bool) {
        UIView.animate(withDuration: 0.35) {
            self.view.alpha = 1
            self.navigationController?.navigationBar.alpha = 0.9
            
        }
    }
}
