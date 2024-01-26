//
//  ChatViewController.swift
//  Gardener
//
//  Created by 유현진 on 1/26/24.
//

import UIKit

class ChatViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        // Do any additional setup after loading the view.
    }
    
    private func initUI(){
        self.view.backgroundColor = .systemBackground
        self.navigationController?.navigationBar.tintColor = .black
        // TODO: 백버튼 title 지우기
        self.navigationController?.navigationBar.topItem?.title = ""
    }
    
    func setChatTitle(chatTitle: String){
        self.title = chatTitle
    }
}
