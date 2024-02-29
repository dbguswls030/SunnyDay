//
//  ChatMenuViewController.swift
//  Gardener
//
//  Created by 유현진 on 2/28/24.
//

import UIKit
import SnapKit

class ChatMenuViewController: UIViewController {
    
    private lazy var chatMenuView: ChatMenuView = {
        return ChatMenuView()
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .gray
        
        self.view.addSubview(scrollView)
        self.scrollView.addSubview(chatMenuView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        chatMenuView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    
    
    
}
