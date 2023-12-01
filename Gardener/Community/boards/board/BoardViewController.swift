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
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var boardView: BoardView = {
        return BoardView()
    }()
    
    private lazy var commentView: BoardCommentView = {
        return BoardCommentView()
    }()
    
    private lazy var commentWriteView: CommentWriteView = {
        return CommentWriteView()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        initNavigationBar()
        hideKeyboard()
    }
    
    private func initUI(){
        self.view.backgroundColor = .white
        self.view.addSubview(scrollView)
        self.scrollView.addSubview(boardView)
        self.view.addSubview(commentWriteView)
        
        scrollView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-50)
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
        }
        
        boardView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(GetElementHeightOfBoard().getHeight(model: model!, width: self.view.frame.width))
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let model = model else{
            return 0
        }
        return model.imageUrls.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "boardImageCell", for: indexPath) as? BoardImageCollectionViewCell, let model = model else {
            return UICollectionViewCell()
        }
        cell.initUI()
        cell.setImageUrl(url: model.imageUrls[indexPath.item])
//        cell.isUserInteractionEnabled = false
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 150)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = ImageSildeViewController()
        vc.cur = indexPath.item
        vc.imageUrls = model?.imageUrls
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true)
    }
}
extension BoardViewController: UITextFieldDelegate{
    
}
