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

class ChatViewController: UIViewController {
    
    // TODO: 임시 ViewModel 만들어서 테스트해보기
    var chatViewModel = ChatViewModel()
    
    var disposeBag = DisposeBag()
    
    private lazy var inputBarView: InputBarView = {
        return InputBarView()
    }()
    
    private lazy var chatCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTouchUpBackground()
        initUI()
        setSendButton()
        setInputBarView()
        initCollectionView()
        
    }
    
    private func initCollectionView(){
        chatCollectionView.delegate = self
        chatCollectionView.register(ChatMyCollectionViewCell.self, forCellWithReuseIdentifier: ChatMyCollectionViewCell.identifier)
        chatCollectionView.register(ChatOtherCollectionViewCell.self, forCellWithReuseIdentifier: ChatOtherCollectionViewCell.identifier)
        
        chatViewModel.chatList
            .bind(to: chatCollectionView.rx.items) { collectionView, index, model in
                if model.uid == "My"{
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
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(inputBarView.snp.top)
        }
        
        inputBarView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(self.view.keyboardLayoutGuide.snp.top)
        }
//        inputBarView.sizeToFit()
    }
    
    func setChatTitle(chatTitle: String){
        self.title = chatTitle
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
        
        // 버튼을 누르면
        // textView에 있는 내용과 여러 정보들을 포함해서
        // chatList subject에 next로 전달하는거
        
        inputBarView.sendButton.rx
            .tap
            .map{
                let message = self.inputBarView.inputTextView.text ?? ""
                self.inputBarView.inputTextView.text = ""
                return ChatModel(profileImageURL: "", nickName: "나", message: message, date: Date(), uid: "My")
            }
            .scan([]) { chatModels, newChatModel in
                return chatModels + [newChatModel]
            }
            .startWith([])
            .bind(to: self.chatViewModel.chatList)
            .disposed(by: disposeBag)
    }
    
    private func configureCell(collectionView: UICollectionView, index: Int, model: ChatModel) -> UICollectionViewCell{
        if model.uid == "My"{
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
        guard let cell = self.configureCell(collectionView: collectionView, index: indexPath.item, model: chatViewModel.getChatModel(at: indexPath.item)!) as? ChatMyCollectionViewCell else{
            return CGSize(width: collectionView.bounds.size.width, height: 100)
        }
        return CGSize(width: collectionView.bounds.size.width, height: cell.getTextViewHeight())
//        return CGSize(width: collectionView.bounds.size.width, height: 100)
    }
}
