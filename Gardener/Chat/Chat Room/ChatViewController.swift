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

class ChatViewController: UIViewController {
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    private func initCollectionView(){
        chatCollectionView.delegate = self
        
        let topInset = navigationController?.navigationBar.isTranslucent == true ? 0 : navigationController?.navigationBar.frame.height ?? 0
        chatCollectionView.contentInset = UIEdgeInsets(top: topInset + 10, left: 0, bottom: 5, right: 0)
        
        chatCollectionView.register(ChatMyCollectionViewCell.self, forCellWithReuseIdentifier: ChatMyCollectionViewCell.identifier)
        chatCollectionView.register(ChatOtherCollectionViewCell.self, forCellWithReuseIdentifier: ChatOtherCollectionViewCell.identifier)
        
        
        
        chatViewModel.getChatMessageListener()
            .bind(to: chatCollectionView.rx.items) { collectionView, index, model in
                if model.uid == Auth.auth().currentUser!.uid{
                    let cell = self.chatCollectionView.dequeueReusableCell(withReuseIdentifier: ChatMyCollectionViewCell.identifier, for: IndexPath(item: index, section: 0)) as! ChatMyCollectionViewCell
                
                    cell.setData(model: model)
                    
                    return cell
                }else{
                    let cell = self.chatCollectionView.dequeueReusableCell(withReuseIdentifier: ChatOtherCollectionViewCell.identifier, for: IndexPath(item: index, section: 0)) as! ChatOtherCollectionViewCell
                    
                    cell.setData(model: model)
                    
                    return cell
                }
            }
            .disposed(by: disposeBag)
        
    }
    
    private func initUI(){
        self.view.backgroundColor = .systemBackground
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationController?.navigationBar.topItem?.title = ""
        
        self.view.addSubview(chatCollectionView)
        self.view.addSubview(inputBarView)

        chatCollectionView.snp.makeConstraints { make in
//            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
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
            .observe(on: MainScheduler.instance)
            .map{
                let indexPath = IndexPath(item: self.chatCollectionView.numberOfItems(inSection: 0) - 1, section: 0)
                self.chatCollectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
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
