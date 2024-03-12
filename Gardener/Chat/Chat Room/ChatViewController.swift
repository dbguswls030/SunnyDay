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

class ChatViewController: UIViewController, UIContextMenuInteractionDelegate{

    var chatViewModel: ChatViewModel
    
    var disposeBag = DisposeBag()
    
    var messageCellHeightDictionary: [IndexPath: CGFloat] = [:]
    
    var menuInteraction: UIContextMenuInteraction?
    
    private lazy var inputBarView: InputBarView = {
        return InputBarView()
    }()
    
    private lazy var messageTableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.showsHorizontalScrollIndicator = false
        tableView.alwaysBounceVertical = true
        tableView.estimatedSectionHeaderHeight = 0
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.layer.removeAllAnimations()
        tableView.estimatedRowHeight = 45
        tableView.separatorInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        tableView.isUserInteractionEnabled = true
        return tableView
    }()
    
    private lazy var menuButton: UIButton = {
        let button = UIButton()
        button.tintColor = .black
        button.setImage(UIImage(systemName: "line.horizontal.3",withConfiguration: UIImage.SymbolConfiguration(pointSize: 22)), for: .normal)
        return button
    }()

    init(chatRoomId: String) {
        self.chatViewModel = ChatViewModel(chatRoomId: chatRoomId)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTouchUpBackground()
        addMessageContextMenu()
        initUI()
        setChatTitle()
        setSendButton()
        setInputBarView()
        initMessageTableView()
        initNavigationItem()
        menuButtonAction()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.backgroundColor = .clear
        self.navigationController?.navigationBar.alpha = 0.9
    }
  
    private func initNavigationItem(){
        self.navigationItem.setRightBarButton(UIBarButtonItem(customView: menuButton), animated: false)
    }
    
    private func menuButtonAction(){
        self.menuButton.rx
            .tap
            .bind{
                let vc = ChatMenuViewController(chatRoomModel: self.chatViewModel.chatRoomModel.asObservable())
                vc.setData(model: self.chatViewModel.chatRoomModel)
                let menuVC = SideMenuNavigationController(rootViewController: vc)
                
                menuVC.presentationStyle = .menuSlideIn
                menuVC.menuWidth = self.view.frame.width * 0.8
                menuVC.sideMenuDelegate = self
                menuVC.statusBarEndAlpha = 0.0
                self.present(menuVC, animated: true)
                
            }.disposed(by: disposeBag)
    }
    
    private func initMessageTableView(){
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
//        let topInset = navigationController?.navigationBar.frame.height ?? 0
        messageTableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 5, right: 0)
        
        messageTableView.register(MyMessageTableViewCell.self, forCellReuseIdentifier: MyMessageTableViewCell.identifier)
        messageTableView.register(OtherMessageTableViewCell.self, forCellReuseIdentifier: OtherMessageTableViewCell.identifier)
        
        chatViewModel.getFirstChatMessages()
            .bind { [weak self] in
                guard let self = self else { return }
                self.messageTableView.reloadData()
                DispatchQueue.main.async {
                    if self.messageTableView.contentSize.height > self.messageTableView.bounds.height{
                        let contentHeight = self.messageTableView.contentSize.height
                        let offsetY = max(0, contentHeight - self.messageTableView.bounds.size.height + 10)
                        self.messageTableView.setContentOffset(CGPoint(x: 0, y: offsetY), animated: false)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        chatViewModel.addListenerChatMessages()
            .skip(1)
            .bind{ [weak self] messages ,newMessages in
                guard let self = self else {return}
                self.chatViewModel.messages.accept(messages+newMessages)
                let startIndex = self.messageTableView.numberOfRows(inSection: 0)
                let endIndex = startIndex + newMessages.count
                let indexPaths = (startIndex..<endIndex).map { IndexPath(item: $0, section: 0) }
                
                self.messageTableView.insertRows(at: indexPaths, with: .bottom)
                DispatchQueue.main.async {
                    self.messageTableView.scrollToRow(at:IndexPath(row: self.messageTableView.numberOfRows(inSection: 0) - 1, section: 0), at: .none, animated: false)
                }
            }.disposed(by: disposeBag)
        
        messageTableView.rx.contentOffset
            .map{ contentOffset -> Bool in
                return contentOffset.y < 100 && contentOffset.y > 0
            }
            .distinctUntilChanged()
            .filter{$0}
            .bind{ [weak self] _ in
                guard let self = self else { return }
                self.chatViewModel.getPreviousMessages()
                    .bind{ preCount in
//                        UIView.setAnimationsEnabled(false)
                        let indexPaths = (0..<preCount).map{ IndexPath(row: $0, section: 0)}
                        self.messageTableView.insertRows(at: indexPaths, with: .none)
//                        UIView.setAnimationsEnabled(true)
                    }.disposed(by: self.disposeBag)
            }.disposed(by: disposeBag)
    }

    private func initUI(){
        self.view.backgroundColor = .systemBackground
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationController?.navigationBar.topItem?.title = ""
        
        self.view.addSubview(messageTableView)
        self.view.addSubview(inputBarView)
        
        messageTableView.snp.makeConstraints { make in
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
        chatViewModel.getChatRoomTitle()
            .bind{ title in
                self.title = title
            }
            .disposed(by: disposeBag)
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
            .bind{ [weak self] text in
                guard let self = self else {return}
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
            .map{ [weak self] in
                let message = self?.inputBarView.inputTextView.text ?? ""
                self?.inputBarView.inputTextView.text = ""
                return ChatMessageModel(uid: Auth.auth().currentUser!.uid, message: message, date: Date())
            }.flatMap{ [weak self] messageModel in
                FirebaseFirestoreManager.shared.sendChatMessage(chatRoomId: self!.chatViewModel.chatRoomId, message: messageModel)
            }
            .bind{}
            .disposed(by: disposeBag)
    }
    
    private func addMessageContextMenu(){
        menuInteraction = .init(delegate: self)
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(actionProvider:  { [unowned self] suggestedActions in
            let copyAction = UIAction(title: "복사", image: UIImage(systemName: "doc.on.doc")) { _ in
                print("복사하기")
            }
            let shareAction = UIAction(title: "공유",image: UIImage(systemName: "square.and.arrow.up")) { _ in
                print("공유하기")
            }
            let menu = UIMenu(preferredElementSize: .large, children: suggestedActions + [copyAction,  shareAction])

            return menu
        })
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


extension ChatViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        chatViewModel.messages.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let model = chatViewModel.getChatModel(at: indexPath.row) else {
            return UITableViewCell()
        }
        
        if model.uid == Auth.auth().currentUser!.uid{
            let cell = self.messageTableView.dequeueReusableCell(withIdentifier: MyMessageTableViewCell.identifier, for: IndexPath(row: indexPath.row, section: 0)) as! MyMessageTableViewCell
            cell.setData(model: model)
            cell.addMenuInteraction(vc: self)
            return cell
        }else{
            let cell = self.messageTableView.dequeueReusableCell(withIdentifier: OtherMessageTableViewCell.identifier, for: IndexPath(row: indexPath.row, section: 0)) as! OtherMessageTableViewCell
            cell.setData(model: model)
            cell.addMenuInteraction(vc: self)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        messageCellHeightDictionary[indexPath] = cell.frame.size.height
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return messageCellHeightDictionary[indexPath] ?? 45
    }
    
//    func tableView(_ tableView: UITableView, shouldSpringLoadRowAt indexPath: IndexPath, with context: UISpringLoadedInteractionContext) -> Bool {
//        return false
//    }
}
extension ChatViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return false
    }
}
