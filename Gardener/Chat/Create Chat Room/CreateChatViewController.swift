//
//  CreateChatViewController.swift
//  Gardener
//
//  Created by 유현진 on 2/6/24.
//

import UIKit
import RxSwift
import SnapKit
import RxCocoa

class CreateChatViewController: UIViewController {

    var disposeBag = DisposeBag()
    
    private lazy var topView: UIView = {
        var view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        var label = UILabel()
        label.text = "채팅방 만들기"
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    private lazy var backButton: UIButton = {
        var button = UIButton()
        button.tintColor = .black
        button.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        return button
    }()
    
    private lazy var scrollView: UIScrollView = {
        var scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var createChatView: CreateChatView = {
        return CreateChatView()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        hideKeyboardWhenTouchUpBackground()
        initUI()
        backButtonAction()
    }
    

    private func initUI(){
        self.view.backgroundColor = .systemBackground
        self.view.addSubview(topView)
        self.view.addSubview(scrollView)
        self.topView.addSubview(titleLabel)
        self.topView.addSubview(backButton)
        self.scrollView.addSubview(createChatView)
        
        topView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.height.equalTo(45)
        }
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(self.view.keyboardLayoutGuide.snp.top)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }
        
        backButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.width.height.equalTo(45)
        }
        
        createChatView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview().offset(1)
        }
    }

    @objc private func backButtonAction(){
        self.dismiss(animated: true)
    }
}
