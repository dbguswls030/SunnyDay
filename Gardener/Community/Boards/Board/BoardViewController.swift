//
//  BoardViewController.swift
//  Gardener
//
//  Created by 유현진 on 2023/11/07.
//

import UIKit
import SnapKit

class BoardViewController: UIViewController {
    
    private weak var model: BoardModel?
    
    private lazy var commentViewModel: CommentViewModel = {
        return CommentViewModel()
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initCommentCollectionView()
        initUI()
        initViewModel()
        
        initNavigationBar()
        hideKeyboard()
    }
    
    private func initViewModel(){
        guard let model = model else { return }
        self.commentViewModel.setViewModel(boardId: model.boardId) {
            self.commentView.setCommentCount(count: self.commentViewModel.numberOfModel())
            self.commentView.setLabel(count: self.commentViewModel.numberOfModel())
            self.commentView.commentCollectionView.reloadData()

            DispatchQueue.main.async {
                let margin = self.commentViewModel.numberOfModel() * 5
                self.commentView.snp.updateConstraints { make in
                    make.height.equalTo(45 + Int(self.commentView.commentCollectionView.contentSize.height) + margin)
                }
            }
        }
    }
    private func initUI(){
        self.view.backgroundColor = .white
        self.view.addSubview(scrollView)
        self.scrollView.addSubview(boardView)
        self.scrollView.addSubview(commentView)
        self.view.addSubview(commentWriteView)
        
        scrollView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-50)
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
    }
    
    private func initNavigationBar(){
        let backButton = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        backButton.tintColor = .black
        self.title = "자유"
        self.navigationItem.backBarButtonItem = backButton
    }
}

extension BoardViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func initImageCollectionView(){
        if model?.imageUrls.count != 0{
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
            return model.imageUrls.count
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
            cell.setImageUrl(url: model.imageUrls[indexPath.item])
            return cell
        }else{
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "commentCell", for: indexPath) as? CommentCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.setDate(date: commentViewModel.getDate(index: indexPath.item))
            cell.setContent(content: commentViewModel.getContent(index: indexPath.item))
            if commentViewModel.getDept(index: indexPath.item) == 1{
                cell.updateConstraintsWithDept()
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.boardView.imageCollectionView{
            return CGSize(width: 150, height: 150)
        }else{
            if commentViewModel.getDept(index: indexPath.item) == 0 {
                return CGSize(width: self.view.frame.width, height: 40 + 5 + GetElementHeightOfComment().getContentsHeight(contents: commentViewModel.getContent(index: indexPath.item), width: self.view.frame.width - 10 - 45 - 12 - 10) )
            }else{
                
                return CGSize(width: self.view.frame.width, height: 40 + 5 + GetElementHeightOfComment().getContentsHeight(contents: commentViewModel.getContent(index: indexPath.item), width: self.view.frame.width - 20 - 90 - 24 - 10) )
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.boardView.imageCollectionView{
            let vc = ImageSildeViewController()
            vc.cur = indexPath.item
            vc.imageUrls = model?.imageUrls
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true)
        }
    }
}

class GetElementHeightOfBoard{
    // 폰트크기 : 글제목20, 글내용 16
    // 높이 : 사진150, 프로필사진 45
    public func getHeight(model: BoardModel, width: CGFloat) -> CGFloat{
        return 0.5 + 20 + getTitleHeight(title: model.title, width: width) + 20 + getProfilelHeight() + 10 + 0.5 + 20 + getContentsHeight(contents: model.contents, width: width) + 20 + getImagesHeight(imageUrls: model.imageUrls)
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
