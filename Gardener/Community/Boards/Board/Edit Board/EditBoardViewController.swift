//
//  EditContentViewController.swift
//  Gardener
//
//  Created by 유현진 on 1/1/24.
//

import UIKit
import FirebaseAuth
class EditBoardViewController: CreateBoardViewController {
    var model: BoardModel?
    
    weak var editDelegate: DelegateEditBoard?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationBar()
        // Do any additional setup after loading the view.
    }
    
    func setData(){
        guard let model = model else { return }
        self.contentTextView.text = model.contents
        self.contentTextView.textColor = .black
        self.contentLimitLabel.text = "(\(contentTextView.text!.count)/300)"
        self.titleTextView.text = model.title
        self.categoryLabel.text = model.category
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        model.contentImageURLs.forEach { [weak self] url in
            self?.showActivityIndicator(alpha: 0.2)
            UIImage().setImage(url: url) { image in
                if let image = image {
                    self?.selectedImage.append(image)
                    if self?.selectedImage.count == model.contentImageURLs.count{
                        dispatchGroup.leave()
                    }
                }
            }
        }
        
        dispatchGroup.notify(queue: .global(), work: DispatchWorkItem(block: {
            DispatchQueue.main.async { [weak self] in
                self?.hideActivityIndicator(alpha: 0.2)
                self?.photoCollectionView.reloadData()
            }
        }))
    }
    
    override func initNavigationBar(){
        self.navigationItem.title = "게시글 수정"
        self.navigationItem.setRightBarButton(UIBarButtonItem(image: UIImage(systemName: "arrow.up"), style: .done, target: self, action: #selector(editBoard)), animated: true)
        self.navigationItem.rightBarButtonItem?.tintColor = .black
    }
    
    @objc private func editBoard(_ sender: UIBarButtonItem){
        // TODO: 게시글 수정 API
        guard let category = categoryLabel.text, category != "카테고리를 선택해 주세요." else{
            print("카테고리를 선택해 주세요.")
//            Toast().showToast(view: self.view, message: "카테고리를 선택해 주세요.")
            return
        }
        
        guard let contents = contentTextView.text, contents.count > 1, contents != "내용을 입력해 주세요." else{
//            Toast().showToast(view: self.view, message: "내용을 최소 두 글자 이상 입력해주세요.")
            print("내용을 최소 두 글자 이상 입력해주세요.")
            return
        }
        
        guard let title = titleTextView.text, title.count > 1 else{
//            Toast().showToast(view: self.view, message: "제목을 최소 두 글자 이상 입력해주세요.")
            print("제목을 최소 두글자 이상 입력해 주세요")
            return
        }
        guard let model = model else {
            print("model is empty")
            return
        }
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        showActivityIndicator(alpha: 0.0)
        if let uid = Auth.auth().currentUser?.uid{
            FirebaseFirestoreManager.shared.getUserInfo(uid: uid) { [weak self] userModel in
                guard let self = self else { return }
                FirebaseStorageManager.shared.uploadBoardImages(images: self.selectedImage, boardId: model.boardId, uid: uid) { [weak self] contentImageURLs in
                    guard let self = self else { return }
                    FirebaseFirestoreManager.shared.updateBoard(documentId: model.documentId!, model: BoardModel(boardId: model.boardId, category: category, title: title, contents: contents, uid: uid, nickName: userModel.nickName, profileImageURL: userModel.profileImageURL, contentImageURLs: contentImageURLs)) {
                        FirebaseFirestoreManager.shared.getBoard(documentId: model.documentId!) { [weak self] boardModel in
                            guard let self = self else { return }
                            self.editDelegate?.endEditBoard(model: boardModel)
                            self.hideActivityIndicator(alpha: 0.0)
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
        }
        
    }
}

