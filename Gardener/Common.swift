//
//  Common.swift
//  Gardener
//
//  Created by 유현진 on 2023/06/05.
//

import Foundation
import UIKit
import SnapKit

protocol SendDelegateWhenPop: AnyObject{
    func popDeleteBoard()
}

protocol DelegateEditBoard: AnyObject{
    func endEditBoard(model: BoardModel)
}

protocol DelegateEditComment: AnyObject{
    func endEditComment()
}

enum BoardCategory: String, CaseIterable{
    case free = "자유"
    case question = "질문/답변"
}

class BreakLine: UIView{
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .lightGray
        self.alpha = 0.3
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PopUpViewController: UIViewController{

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "정말 댓글을 삭제하시겠습니까?"
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    lazy var confirmButton: UIButton = {
        let button = UIButton()
        button.setTitle("확인", for: .normal)
        button.backgroundColor = .green.withAlphaComponent(0.3)
        button.layer.cornerRadius = 8
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("취소", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .lightGray.withAlphaComponent(0.2)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(cancelButtonAction), for: .touchUpInside)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        return button
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 15
        view.sizeToFit()
        return view
    }()
    
    private func initUI(){
        self.view.backgroundColor = .black.withAlphaComponent(0.3)
        self.view.addSubview(contentView)
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(stackView)
        
        contentView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(55)
            make.right.equalToSuperview().offset(-55)
        }
        
        [cancelButton, confirmButton].map{ button in
            self.stackView.addArrangedSubview(button)
            button.snp.makeConstraints { make in
                make.height.equalTo(button.snp.width).multipliedBy(0.3)
            }
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalToSuperview().offset(30)
        }
        
        stackView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    func setTitleLabel(title: String){
        self.titleLabel.text = title
    }

    
    func setConfirmButtonText(text: String){
        self.confirmButton.setTitle(text, for: .normal)
    }
    
    @objc private func cancelButtonAction(){
        self.dismiss(animated: false)
    }
    
    override func viewDidLoad() {
        initUI()
    }
    
}

class MessageLabel: UILabel{
    private var padding = UIEdgeInsets(top: 7, left: 8, bottom: 7, right: 8)

        convenience init(padding: UIEdgeInsets) {
            self.init()
            self.padding = padding
        }

        override func drawText(in rect: CGRect) {
            super.drawText(in: rect.inset(by: padding))
        }

        override var intrinsicContentSize: CGSize {
            var contentSize = super.intrinsicContentSize
            contentSize.height += padding.top + padding.bottom
            contentSize.width += padding.left + padding.right

            return contentSize
        }
}
