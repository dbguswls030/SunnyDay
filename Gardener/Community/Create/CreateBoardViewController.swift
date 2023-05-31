//
//  CreateBoardViewController.swift
//  Gardener
//
//  Created by 유현진 on 2023/05/28.
//

import UIKit

class CreateBoardViewController: UIViewController {
    
    lazy var boardTitleLabel: UILabel = {
       return UILabel()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = .white
        initNavigationBar()
    }
    
    func initNavigationBar(){
        self.navigationItem.title = "글쓰기"
        
    }

}
