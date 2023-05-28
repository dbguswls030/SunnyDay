//
//  CommunityViewController.swift
//  Gardener
//
//  Created by 유현진 on 2023/03/28.
//

import UIKit
import SnapKit

class CommunityViewController: UIViewController {
    
    private lazy var createBoardButton: UIButton = {
        var button = UIButton()
        button.backgroundColor = .green
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initCreateBoardButton()
    }
    
    func initCreateBoardButton(){
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
    
    @objc func showCreatBoardView(){
        // MARK: TODO
        // 게시글 작성 뷰 이동
    }
}
