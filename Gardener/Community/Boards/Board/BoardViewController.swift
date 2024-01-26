//
//  BoardViewController.swift
//  Gardener
//
//  Created by 유현진 on 2023/11/07.
//

import UIKit
import SnapKit
import FirebaseAuth

class BoardViewController: UIViewController {
    
    lazy var replyFlag = false
    lazy var commentId: Int? = nil
    
    private var model: BoardModel?
    weak var delegate: SendDelegateWhenPop?
    
    private lazy var commentViewModel: CommentViewModel = {
        return CommentViewModel()
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = .systemGray5
        return scrollView
    }()
    
    private lazy var boardView: BoardView = {
        return BoardView()
    }()
    
    private lazy var commentView: CommentView = {
        return CommentView()
    }()
    
    private lazy var commentWriteView: CommentWriteView = {
        return CommentWriteView()
    }()
    
    private lazy var replyNoticeView: ReplyNoticeView = {
        return ReplyNoticeView()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        initCommentCollectionView()
        initNavigationBar()
        hideKeyboard()
        setLikeButtonState()
    }
    override func viewWillAppear(_ animated: Bool) {
        initCommentViewModel()
        addLikeBoardButtonTarget()
    }
    
    private func initCommentViewModel(){
        guard let model = model, let documentId = model.documentId  else {
            print("model is empty")
            return
        }
        self.commentViewModel.setCommentModel(documentId: documentId) { [weak self] in
            guard let self = self else { return }
            if self.commentViewModel.numberOfModel() == 0 {
                return
            }
            FirebaseFirestoreManager.shared.getBoard(documentId: documentId) { model in
                self.model = model
                self.commentView.setCommentCount(count: model.commentCount)
            }

            self.commentView.setLabel(count: self.commentViewModel.numberOfModel())
            self.commentView.commentCollectionView.reloadData()
            
            DispatchQueue.main.async {
//                let margin = (self.commentViewModel.numberOfModel() - 1) * 8
                self.commentView.snp.updateConstraints { make in
                    make.height.equalTo(35 + self.commentView.getCommentLabelHeight() + Int(self.commentView.commentCollectionView.contentSize.height))
                }
            }
            
        }
    }
    
    private func setLikeButtonState(){
        guard let model = model else {return}
        if let userId = Auth.auth().currentUser?.uid {
            FirebaseFirestoreManager.shared.checkLikeBoard(documentId: model.documentId!, userId: userId) { [weak self] isLike in
                self?.boardView.setLikeButton(isLike: isLike)
            }
        }
    }
    
    private func initUI(){
        self.view.backgroundColor = .systemBackground
        self.view.addSubview(scrollView)
        self.scrollView.addSubview(boardView)
        self.scrollView.addSubview(commentView)
        self.view.addSubview(commentWriteView)
        
        scrollView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(commentWriteView.snp.top)
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
        }
        
        boardView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(GetElementHeightOfBoard().getHeight(model: model!, width: self.view.frame.width))
        }
        
        commentView.snp.makeConstraints { make in
            make.top.equalTo(boardView.snp.bottom).offset(8)
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(200)
        }
        
        commentWriteView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(self.view.keyboardLayoutGuide.snp.top)
        }
        commentWriteView.sizeToFit()
        commentWriteView.sendButton.addTarget(self, action: #selector(writeComment), for: .touchUpInside)
    }
    
    private func initReplyNoticeView(){
        self.view.addSubview(replyNoticeView)
        
        replyNoticeView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(commentWriteView.snp.top)
        }
        
        replyNoticeView.cancelButton.addTarget(self, action: #selector(deinitReplyNoticeView), for: .touchUpInside)
        
        scrollView.snp.remakeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(replyNoticeView.snp.top)
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
        }
//        scrollView.snp.updateConstraints { make in
//            make.bottom.equalTo(replyNoticeView.snp.top)
//        }
    }
    
    @objc private func deinitReplyNoticeView(){
        scrollView.snp.remakeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(commentWriteView.snp.top)
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
        }
        replyNoticeView.removeFromSuperview()
        
        commentWriteView.resetTextView()
        resetReplyMode()
    }
    
    private func resetReplyMode(){
        self.commentId = nil
        self.replyFlag = false
    }
    
    private func reinitCommentViewModel(){
        self.commentViewModel.resetViewModel()
        initCommentViewModel()
    }

    @objc private func writeComment(){
        guard let model = model else { return }
        self.dismissKeyboard()
        showActivityIndicator(alpha: 0.0)
        self.commentWriteView.sendButton.isEnabled = false
        let dept = replyFlag == false ? 0 : 1
        let parentId: Int
        if commentId == nil{
            parentId = Int(Date().timeIntervalSince1970)
        }else{
            parentId = commentId!
        }
        let comment = self.commentWriteView.getCommentContent()
        if let uid = Auth.auth().currentUser?.uid{
            FirebaseFirestoreManager.shared.getUserInfo(uid: uid) { [weak self] userModel in
                guard let self = self else { return }
                FirebaseFirestoreManager.shared.uploadComment(documentId: model.documentId!, commentModel: CommentModel(parentId: parentId, content: comment, dept: dept, userId: uid, profileImageURL: userModel.profileImageURL, nickName: userModel.nickName)) { [weak self] in
                    guard let self = self else { return }
                    self.reinitCommentViewModel()
                    self.commentWriteView.resetTextView()
                    if self.replyFlag == true{
                        self.deinitReplyNoticeView()
                    }
                    self.hideActivityIndicator(alpha: 0.0)
                }
            }
        }
    }
        
    func setBoardModel(model: BoardModel){
        self.model = model
        initImageCollectionView()
        setData()
    }
    
    func setNavigationTitle(category: String){
        self.title = category
    }
    
    func setData(){
        guard let model = model else{
            return
        }
        boardView.setTitle(title: model.title)
        boardView.setDate(date: model.date)
        boardView.setContents(contents: model.contents)
        boardView.setNickName(nickName: model.nickName)
        boardView.setProfileImage(profileImageURL: model.profileImageURL)
        boardView.setLikeCount(likeCount: model.likeCount)
        commentView.setCommentCount(count: model.commentCount)
    }
    
    private func initNavigationBar(){
        let backButton = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        backButton.tintColor = .black
        self.title = "자유"
//        ellipsis
        self.navigationItem.backBarButtonItem = backButton
        guard let model = model else { return }
        if model.uid == Auth.auth().currentUser?.uid{
            
//            let button = UIButton(type: .custom)
//            button.addTarget(self, action: #selector(touchUpOptionButton), for: .touchUpInside)
//            button.setImage(UIImage(systemName: "ellipsis", withConfiguration: UIImage.SymbolConfiguration.init(pointSize: 55)), for: .normal)
//            button.tintColor = .black
//            button.imageView?.contentMode = .scaleAspectFit
//            button.imageView?.transform = .init(rotationAngle: .pi/2)
            
            let optionButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), style: .plain, target: self, action: #selector(touchUpBoardOptionButton))
            optionButton.tintColor = .black
//            let optionBButton = UIBarButtonItem(customView: button)
            self.navigationItem.rightBarButtonItem = optionButton
        }
    }

    private func addLikeBoardButtonTarget(){
        boardView.likeButton.addTarget(self, action: #selector(likeBoard), for: .touchUpInside)
    }
    
    @objc private func likeBoard(){
        guard let documentId = model!.documentId else{ return }
        if let uid = Auth.auth().currentUser?.uid{
            if boardView.likeButton.isSelected == false{
                FirebaseFirestoreManager.shared.likeBoard(documentId: documentId, userId: uid) { [weak self] in
                    FirebaseFirestoreManager.shared.getBoard(documentId: documentId) { [weak self] model in
                        self?.model = model
                        self?.boardView.setLikeCount(likeCount: model.likeCount)
                        self?.boardView.toggleLikeButton()
                    }
                }
            }else{
                FirebaseFirestoreManager.shared.unLikeBoard(documentId: documentId, userId: uid) { [weak self] in
                    FirebaseFirestoreManager.shared.getBoard(documentId: documentId) { [weak self] model in
                        self?.model = model
                        self?.boardView.setLikeCount(likeCount: model.likeCount)
                        self?.boardView.toggleLikeButton()
                    }
                }
            }
        }
    }
    
    @objc private func likeComment(_ sender: UICommentLikeButton){
        
        guard let boardDocumentId = model!.documentId else { return }
        guard let commentDocumentId = commentViewModel.getDocumentId(index: sender.index!) else { return }
                
        if let uid = Auth.auth().currentUser?.uid{
            if sender.isSelected == false{
                FirebaseFirestoreManager.shared.likeComment(boardDocumentId: boardDocumentId, commentDocumentId: commentDocumentId, userId: uid) {
                    FirebaseFirestoreManager.shared.getComment(boardDocumentId: boardDocumentId, commentDocumentId: commentDocumentId) { CommentModel in
                        sender.setLikeCount(likeCount: CommentModel.likeCount)
                        sender.tintColor = .green
                        sender.isSelected.toggle()
                    }
                }
            }else{
                FirebaseFirestoreManager.shared.unLikeComment(boardDocumentId: boardDocumentId, commentDocumentId: commentDocumentId, userId: uid) {
                    FirebaseFirestoreManager.shared.getComment(boardDocumentId: boardDocumentId, commentDocumentId: commentDocumentId) { CommentModel in
                        sender.setLikeCount(likeCount: CommentModel.likeCount)
                        sender.tintColor = .lightGray
                        sender.isSelected.toggle()
                    }
                }
            }
        }
    }
    
    @objc private func touchUpBoardOptionButton(_ sender: UIBarButtonItem){
        guard let model = model else { return }
        let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let editBoard = UIAlertAction(title: "글 수정하기", style: .default) { [weak self] _ in
            guard let self = self else { return }
            let vc = EditBoardViewController()
            vc.model = model
            vc.editDelegate = self
            vc.setData()
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        let deleteBoard = UIAlertAction(title: "삭제하기", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            guard let documentId = self.model?.documentId else { return }
            
            showPopUp(title: "정말 게시글을 삭제하시겠습니까?", confirmButtonTitle: "삭제") { [weak self] in
                guard let self = self else { return }
                self.showActivityIndicator(alpha: 0.0)
                FirebaseFirestoreManager.shared.deleteBoard(documentId: documentId) { [weak self] in
                    guard let self = self else { return }
                    self.hideActivityIndicator(alpha: 0.0)
                    self.delegate?.popDeleteBoard()
                    DispatchQueue.main.async {
                        self.dismiss(animated: false)
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
        
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        
        actionSheetController.addAction(editBoard)
        actionSheetController.addAction(deleteBoard)
        actionSheetController.addAction(cancel)
        
        self.present(actionSheetController, animated: true)
    }
    
    @objc private func touchUpCommentOptionButton(_ sender: UICommentOptionButton){
        let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let editBoard = UIAlertAction(title: "댓글 수정하기", style: .default) { [weak self] _ in
            guard let self = self else { return }
            let vc = EditCommentViewController()
            vc.boardDocumentId = model?.documentId!
            vc.model = commentViewModel.getCommentModel(index: sender.index!)
            vc.delegate = self
            vc.setData()
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        let deleteBoard = UIAlertAction(title: "삭제하기", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            guard let boardDocumentId = self.model?.documentId else { return }
            guard let commentDocumentId = commentViewModel.getDocumentId(index: sender.index!) else {return}
            let parentId = commentViewModel.getParentId(index: sender.index!)
            showPopUp(title: "정말 댓글을 삭제하시겠습니까?", confirmButtonTitle: "삭제") { [weak self] in
                guard let self = self else{
                    return
                }
                FirebaseFirestoreManager.shared.deleteComment(boardDocumentId: boardDocumentId, commentDocumentId: commentDocumentId) {
                    FirebaseFirestoreManager.shared.updateCommentThenDeleteComment(documentId: boardDocumentId, parentId: parentId) {
                        self.reinitCommentViewModel()
                        // 댓글이 있었는데 없어졌을 떄
                        FirebaseFirestoreManager.shared.getBoard(documentId: boardDocumentId) { model in
                            self.model = model
                            self.commentView.setCommentCount(count: model.commentCount)
                        }
                        if self.commentViewModel.numberOfModel() == 0{
                            self.commentView.commentCollectionView.reloadData()
                            self.commentView.setLabel(count: self.commentViewModel.numberOfModel())
                            self.commentView.snp.updateConstraints { make in
                                make.height.equalTo(200)
                            }
                        }
                        DispatchQueue.main.async {
                            self.dismiss(animated: false)
                        }
                    }
                }
            }
        }
        
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        if commentViewModel.getUid(index: sender.index!) == Auth.auth().currentUser?.uid{
            actionSheetController.addAction(editBoard)
            actionSheetController.addAction(deleteBoard)
        }
        actionSheetController.addAction(cancel)
        self.present(actionSheetController, animated: true)
    }
}

extension BoardViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func initImageCollectionView(){
        if model?.contentImageURLs.count != 0{
            boardView.imageCollectionView.register(BoardImageCollectionViewCell.self, forCellWithReuseIdentifier: "boardImageCell")
            boardView.imageCollectionView.dataSource = self
            boardView.imageCollectionView.delegate = self
            boardView.initImageCollectionView()
        }
    }
    
    func initCommentCollectionView(){
        commentView.commentCollectionView.register(CommentCollectionViewCell.self, forCellWithReuseIdentifier: "commentCell")
        commentView.commentCollectionView.delegate = self
        commentView.commentCollectionView.dataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if boardView.imageCollectionView == collectionView{
            guard let model = model else{
                return 0
            }
            return model.contentImageURLs.count
        }else{
            return commentViewModel.numberOfModel()
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == boardView.imageCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "boardImageCell", for: indexPath) as? BoardImageCollectionViewCell, let model = model else {
                return UICollectionViewCell()
            }
            cell.initUI()
            cell.setImageUrl(url: model.contentImageURLs[indexPath.item])
            return cell
        }else{
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "commentCell", for: indexPath) as? CommentCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.setDate(date: commentViewModel.getDate(index: indexPath.item))
            cell.setContent(content: commentViewModel.getContent(index: indexPath.item))
            let nickName = commentViewModel.getNickName(index: indexPath.item)
            cell.setNickName(nickName: nickName)
            
            if commentViewModel.getIsHiddenValue(index: indexPath.item) == true{
                cell.setDefaultProfileImage()
            }else{
                cell.setProfileImage(profileImageURL: commentViewModel.getProfileImageURL(index: indexPath.item))
            }
            let parentId = commentViewModel.getParentId(index: indexPath.item)
            
            if commentViewModel.getIsHiddenValue(index: indexPath.item) == false{
                cell.replyButton.initReplyButton(nickName: nickName, parentId: parentId)
                cell.replyButton.addTarget(self, action: #selector(touchUpReplyButton), for: .touchUpInside)
            }
            
            if commentViewModel.getDept(index: indexPath.item) == 1{
                cell.updateConstraintsWithDept()
            }
            
            cell.likeButton.initCommentButton(index: indexPath.item)
            cell.likeButton.setLikeCount(likeCount: commentViewModel.getLikeCount(index: indexPath.item))
            if let boardDocumentId = model?.documentId, let commentDocumentId = commentViewModel.getDocumentId(index: indexPath.item), let uid = Auth.auth().currentUser?.uid{
                cell.setLikeButton(boardDocumentId: boardDocumentId, commentDocumentId: commentDocumentId, userId: uid)
            }
            cell.likeButton.addTarget(self, action: #selector(likeComment(_:)), for: .touchUpInside)
            
            cell.optionButton.initCommentButton(index: indexPath.item)
            cell.optionButton.addTarget(self, action: #selector(touchUpCommentOptionButton(_:)), for: .touchUpInside)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.boardView.imageCollectionView{
            return CGSize(width: 150, height: 150)
        }else{// 40 5 10 20
            if commentViewModel.getDept(index: indexPath.item) == 0 {
                return CGSize(width: self.view.frame.width, height: 45 + 5 + 10 + 20 + GetElementHeightOfComment().getContentsHeight(contents: commentViewModel.getContent(index: indexPath.item) , width: self.view.frame.width - 10 - 45 - 12 - 10) )
            }else{
                return CGSize(width: self.view.frame.width, height: 45 + 5 + 10 + 20 + GetElementHeightOfComment().getContentsHeight(contents: commentViewModel.getContent(index: indexPath.item), width: self.view.frame.width - 20 - 90 - 24 - 10) )
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.boardView.imageCollectionView{
            let vc = ImageSildeViewController()
            vc.cur = indexPath.item
            vc.imageUrls = model?.contentImageURLs
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let boardDocumentId = model!.documentId else { return }

        let contentOffsetY = self.commentView.commentCollectionView.contentOffset.y
        let scrollViewContentSizeY = self.commentView.commentCollectionView.contentSize.height
        let paginationY = self.commentView.commentCollectionView.frame.height
        
        if !commentViewModel.isValidPaging() && !commentViewModel.isLastPage(){
            if contentOffsetY > scrollViewContentSizeY - paginationY{
                let startIndex = commentViewModel.numberOfModel()
                self.commentViewModel.setPaging(data: true)
                self.commentViewModel.setCommentModel(documentId: boardDocumentId) {
                    [weak self] in
                    guard let self = self else {return}
                    let endIndex = self.commentViewModel.numberOfModel()
                    let indexPath = (startIndex..<endIndex).map{ IndexPath(item: $0, section: 0)}
                    self.commentView.commentCollectionView.performBatchUpdates {
                        self.commentView.commentCollectionView.insertItems(at: indexPath)
                    } completion: { finish in
                        if finish{
                            DispatchQueue.main.async {
                                self.commentView.snp.updateConstraints { make in
                                    make.height.equalTo(35 + self.commentView.getCommentLabelHeight() + Int(self.commentView.commentCollectionView.contentSize.height))
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

extension BoardViewController: ReplyButtonDelegate{
    @objc func touchUpReplyButton(_ sender: UIReplyButton){
        guard let nickName = sender.nickName else { return }
        commentWriteView.focusCommentTextView()
        commentWriteView.setReply(nickName: nickName)
        
        self.commentId = sender.parentId
        self.replyFlag = true
        DispatchQueue.main.async {
            self.initReplyNoticeView()
        }
        
        replyNoticeView.setNoticeLabel(nickName: nickName)
    }
}

class GetElementHeightOfBoard{
    // 폰트크기 : 글제목20, 글내용 16
    // 높이 : 사진150, 프로필사진 45
    public func getHeight(model: BoardModel, width: CGFloat) -> CGFloat{
        return 0.5 + 20 + getTitleHeight(title: model.title, width: width) + 20 + getProfilelHeight() + 10 + 0.5 + 20 + getContentsHeight(contents: model.contents, width: width) + 20 + getImagesHeight(imageUrls: model.contentImageURLs) + 70
    }
    
    func getImagesHeight(imageUrls: [String]) -> CGFloat{
        return imageUrls.isEmpty ? 0 : 150 + 20
    }
    
    func getProfilelHeight() -> CGFloat{
        return 45
    }
    
    func getTitleHeight(title: String, width: CGFloat) -> CGFloat{
        let font = UIFont.systemFont(ofSize: 20, weight: .semibold) // 원하는 폰트 및 크기 선택
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let attributes = [NSAttributedString.Key.font: font]
        let boundingRect = (title as NSString).boundingRect(with: size, options: options, attributes: attributes, context: nil)
        return ceil(boundingRect.height)
    }
    
    func getContentsHeight(contents: String, width: CGFloat) -> CGFloat{
        let font = UIFont.systemFont(ofSize: 16) // 원하는 폰트 및 크기 선택
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let attributes = [NSAttributedString.Key.font: font]
        let boundingRect = (contents as NSString).boundingRect(with: size, options: options, attributes: attributes, context: nil)
        return ceil(boundingRect.height)
    }
    
    func getViewCountHeight(viewCount: String, width: CGFloat) -> CGFloat{
        let font = UIFont.systemFont(ofSize: 8, weight: .light) // 원하는 폰트 및 크기 선택
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let attributes = [NSAttributedString.Key.font: font]
        let boundingRect = (viewCount as NSString).boundingRect(with: size, options: options, attributes: attributes, context: nil)
        return ceil(boundingRect.height)
    }
}

class GetElementHeightOfComment{
    func getContentsHeight(contents: String, width: CGFloat) -> CGFloat{
        let font = UIFont.systemFont(ofSize: 16) // 원하는 폰트 및 크기 선택
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let attributes = [NSAttributedString.Key.font: font]
        let boundingRect = (contents as NSString).boundingRect(with: size, options: options, attributes: attributes, context: nil)
        return ceil(boundingRect.height)
    }
}

extension BoardViewController: DelegateEditBoard{
    func endEditBoard(model: BoardModel) {
        self.model = model
        
        setData()
        DispatchQueue.main.async {
            self.boardView.imageCollectionView.reloadData()
        }
    }
}

extension BoardViewController: DelegateEditComment{
    func endEditComment() {
        self.reinitCommentViewModel()
    }
}
