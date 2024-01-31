//
//  ChatViewController.swift
//  Gardener
//
//  Created by 유현진 on 1/26/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class ChatViewController: UIViewController {
    
    // TODO: 임시 ViewModel 만들어서 테스트해보기
    
    
    var disposeBag = DisposeBag()
    
    private lazy var inputBarView: InputBarView = {
        return InputBarView()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboard()
        initUI()
        setSendButton()
        setInputTextView()
    }
    
    private func initUI(){
        self.view.backgroundColor = .systemBackground
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationController?.navigationBar.topItem?.title = ""
        
        self.view.addSubview(inputBarView)
        
        inputBarView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(self.view.keyboardLayoutGuide.snp.top)
        }
//        inputBarView.sizeToFit()
    }
    
    func setChatTitle(chatTitle: String){
        self.title = chatTitle
    }
    
    private func setSendButton(){
        // 텍스트의 유무에 따라 버튼 활성화
        inputBarView.inputTextView.rx.text
            .orEmpty
            .distinctUntilChanged()
            .bind{ text in
                if text.count == 0 {
                    self.inputBarView.sendButton.isEnabled = false
                }else{
                    self.inputBarView.sendButton.isEnabled = true
                }
            }.disposed(by: disposeBag)
        
        // TODO: 버튼 클릭 시
    }
    
    private func setInputTextView(){
        // 텍스트 입력 시 동적 높이 조절
        inputBarView.inputTextView.rx.text
            .orEmpty
            .distinctUntilChanged()
            .bind{ text in
                let size = CGSize(width: self.inputBarView.inputTextView.frame.width, height: .infinity)
                let estimatedSize = self.inputBarView.inputTextView.sizeThatFits(size)

                self.inputBarView.inputTextView.constraints.forEach { constraint in
                    if estimatedSize.height >= 120{
                        self.inputBarView.inputTextView.isScrollEnabled = true
                    }else{
                        self.inputBarView.inputTextView.sizeToFit()
                        self.inputBarView.inputTextView.isScrollEnabled = false
                        if constraint.firstAttribute == .height{
                            constraint.constant = estimatedSize.height
                        }
                    }
                }
            }.disposed(by: disposeBag)
    }
}
