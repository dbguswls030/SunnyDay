//
//  CommunityViewController.swift
//  Gardener
//
//  Created by 유현진 on 2023/03/28.
//

import UIKit
import SnapKit

class CommunityViewController: UIViewController {
    
    private lazy var viewModel: BoardViewModel = {
        return BoardViewModel()
    }()
    
    private lazy var communityView: CommunityView = {
        return CommunityView()
    }()
    
    private lazy var createBoardButton: UIButton = {
        var button = UIButton()
        button.backgroundColor = .green
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initViewModel()
        initUI()
        initNavigationBar()
        initCollectionView()
        initCreateBoardButton()
    }
    
    private func initViewModel(){
        self.viewModel.setBoards()
    }
    
    private func initUI(){
        self.view.addSubview(communityView)
        
        communityView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(tabBarController?.tabBar.frame.size.height ?? 0)
        }
    }
    
    private func initNavigationBar(){
        let backBarButton = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        backBarButton.tintColor = .black
        self.navigationItem.backBarButtonItem = backBarButton
        self.title = "게시판"
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
    }
    
    @objc private func showCreatBoardView(){
        let vc = CreateBoardViewController()
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension CommunityViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource{
    
    private func initCollectionView(){
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
//        cell.setCategroy(categroy: "자유")
//        cell.setContents(contents: "ㅁㄴㅇㅁㄴㅇㅁㄴㅇㅁㄴㅇㅁㄴㅇㅁㄴㅇㅁㄴㅇㅁㄴㅇㅁㄴㅇㅁㄴㅇㅁㄴㅇㅁㄴㅇㅁㄴㅇㅁㄴㅇㅁㄴㅇㅁㄴㅇㅁㄴㅇㅁㄴㅇㅁㄴㅇㅁㄴㅇㅁㄴㅇㅁㄴㅇㅁㄴㅇㅁㄴㅇㅁㄴㅇㅁㄴㅇㅁㄴㅇ")
        return cell
    }
   
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "boardCell", for: indexPath) as? BoardCollectionViewCell else{
            return .zero
        }
        // TODO: viewModel에서 데이터 가져와서 크기 구하기
        return CGSize(width: self.view.frame.width, height:  cell.getHeight())
    }
}
