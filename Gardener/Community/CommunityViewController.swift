//
//  CommunityViewController.swift
//  Gardener
//
//  Created by 유현진 on 2023/03/28.
//

import UIKit
import SnapKit

class ImageTapGestureRecognizer: UITapGestureRecognizer{
    var index: Int?
}

class CommunityViewController: UIViewController{
    
    private lazy var viewModel: BoardViewModel = {
        return BoardViewModel()
    }()
    
    private lazy var communityView: CommunityView = {
        return CommunityView()
    }()
    
    private lazy var refresh: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshCollectionView), for: .valueChanged)
        return refreshControl
    }()
    
    private lazy var createBoardButton: UIButton = {
        var button = UIButton()
        button.backgroundColor = .green
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        initBoardCollectionView()
        initNavigationBar()
        initCreateBoardButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshViewModel()
    }
    
    func refreshViewModel(){
        self.viewModel.reloadViewModel()
        initBoardViewModel()
    }
    
    private func initBoardViewModel(){
        self.viewModel.setBoardModel { [weak self] in
            guard let self = self else {return}
            DispatchQueue.main.async { [weak self] in
                self?.communityView.boardCollectionView.reloadData()
            }
        }
    }
    
    private func initUI(){
        self.view.addSubview(communityView)
        self.view.backgroundColor = .systemBackground
        communityView.snp.makeConstraints { make in
//            make.top.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-(tabBarController?.tabBar.frame.size.height ?? 0))
        }
    }
    
    private func initNavigationBar(){
        let backBarButton = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        backBarButton.tintColor = .black
        self.navigationItem.backBarButtonItem = backBarButton
        self.title = "게시판"
//        self.navigationController?.navigationBar.backgroundColor = .white
        // TODO: 네비게이션 바 아래 그림자
    }

    private func initCreateBoardButton(){
        self.view.addSubview(createBoardButton)
        let buttonSize = 60
        
        createBoardButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-((tabBarController?.tabBar.frame.size.height ?? 0) + 15))
            make.trailing.equalToSuperview().offset(-15)
            make.width.height.equalTo(buttonSize)
        }
        
        createBoardButton.layer.cornerRadius = CGFloat(buttonSize/2)
        createBoardButton.addTarget(self, action: #selector(showCreatBoardView), for: .touchUpInside)
        // TODO: 테두리 그림자
    }
    
    @objc private func showCreatBoardView(){
        let vc = CreateBoardViewController()
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func refreshCollectionView(){
        refreshViewModel()
        refresh.endRefreshing()
    }
    
    private func showBoardContent(index: Int){
        let boardViewController = BoardViewController()
        boardViewController.setBoardModel(model: viewModel.getBoard(index: index))
        boardViewController.delegate = self
        boardViewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(boardViewController, animated: true)
    }
    
    @objc func showBoardContentByImageCollectionView(sender: ImageTapGestureRecognizer){
        showBoardContent(index: sender.index!)
    }
}

extension CommunityViewController: SendDelegateWhenPop{
    func popDeleteBoard(){
        refreshViewModel()
    }
}

extension CommunityViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIGestureRecognizerDelegate{
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
    
    private func initBoardCollectionView(){
        communityView.boardCollectionView.refreshControl = refresh
        communityView.boardCollectionView.delegate = self
        communityView.boardCollectionView.dataSource = self
        communityView.boardCollectionView.register(BoardCollectionViewCell.self, forCellWithReuseIdentifier: "boardCell")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfBoards()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "boardCell", for: indexPath) as? BoardCollectionViewCell else{
            return UICollectionViewCell()
        }

        cell.initUI()
        cell.setModel(model: viewModel.getBoard(index: indexPath.item))
        cell.boardCellView.imageCollectionView.reloadData()
        let tapRecognize = ImageTapGestureRecognizer(target: self, action: #selector(showBoardContentByImageCollectionView))
        tapRecognize.delegate = self
        tapRecognize.index = indexPath.item
        cell.boardCellView.imageCollectionView.addGestureRecognizer(tapRecognize)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showBoardContent(index: indexPath.item)
    }
   
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width, height: viewModel.getHeight(index: indexPath.item, width: self.view.frame.width - 20 - 20))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffsetY = self.communityView.boardCollectionView.contentOffset.y
        let collectionViewContentSizeY = self.communityView.boardCollectionView.contentSize.height
        let paginationY = self.communityView.boardCollectionView.frame.height

        if !viewModel.isValidPaging() && !viewModel.isLastPage(){
            if contentOffsetY > collectionViewContentSizeY - paginationY{
                let startIndex = viewModel.numberOfBoards()
                self.viewModel.setPaging(data: true)
                self.viewModel.setBoardModel { [weak self] in
                    guard let self = self else {return}
                    let endIndex = self.viewModel.numberOfBoards()
                    let indexPath = (startIndex..<endIndex).map{ IndexPath(item: $0, section: 0)}
                    self.communityView.boardCollectionView.performBatchUpdates ({
                            self.communityView.boardCollectionView.insertItems(at: indexPath)
                    })
                }
            }
        }
    }
}
