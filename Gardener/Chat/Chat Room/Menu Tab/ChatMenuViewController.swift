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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    private func initUI(){
        self.view.backgroundColor = .systemBackground
        self.view.addSubview(scrollView)
        self.scrollView.addSubview(chatMenuView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            
        }
        chatMenuView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
    }
    
    func setData(model: ChatRoomModel){
        chatMenuView.setData(model: model)
    }
}
