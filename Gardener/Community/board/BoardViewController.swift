//
//  BoardViewController.swift
//  Gardener
//
//  Created by 유현진 on 2023/11/07.
//

import UIKit

class BoardViewController: UIViewController {

    private lazy var boardView: BoardView = {
        return BoardView()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
        initNavigationBar()
    }
    
    private func initUI(){
        self.view.backgroundColor = .white
    }
    
    private func initNavigationBar(){
        let backButton = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        backButton.tintColor = .black
        self.navigationItem.backBarButtonItem = backButton
    }
}
