//
//  CreateChatView.swift
//  Gardener
//
//  Created by 유현진 on 2/8/24.
//

import UIKit
import RxSwift
import SnapKit
import RxCocoa

class CreateChatView: UIView {
    
    var disposeBag = DisposeBag()
    
    private lazy var thumnailImage: UIButton = {
        var button = UIButton()
        button.setImage(UIImage(named: "ralo"), for: .normal)
        button.clipsToBounds = true
        return button
    }()
    
    private lazy var titleTextField: UITextField = {
        var textField = UITextField()
        textField.placeholder = "채팅방 이름을 입력해 주세요."
        textField.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        return textField
    }()
    
    private lazy var titleTextLimitLabel: UILabel = {
        var label = UILabel()
        label.textColor = .lightGray
        label.text = "0/15"
        label.font = UIFont.systemFont(ofSize: 11, weight: .light)
        return label
    }()
    
    private lazy var subTitleTextView: UITextView = {
        var textView = UITextView()
        textView.isScrollEnabled = false
        textView.textColor = .lightGray
        textView.text = "#해시태그로 채팅방을 소개해 주세요."
        textView.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        textView.returnKeyType = .done
        return textView
    }()
    
    private lazy var subTitleLimitLabel: UILabel = {
        var label = UILabel()
        label.textColor = .lightGray
        label.text = "0/60"
        label.font = UIFont.systemFont(ofSize: 11, weight: .light)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initUI()
        changedTitleTextField()
        changedSubTitleTextField()
        setCustomSubTitleTextViewReturnKey()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initUI(){
        self.backgroundColor = .systemBackground
        
        self.addSubview(thumnailImage)
        self.addSubview(titleTextField)
        self.addSubview(titleTextLimitLabel)
        self.addSubview(subTitleTextView)
        self.addSubview(subTitleLimitLabel)
        
        thumnailImage.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(100)
        }
        
        titleTextField.snp.makeConstraints { make in
            make.top.equalTo(thumnailImage.snp.bottom).offset(35)
            make.left.equalToSuperview().offset(25)
            make.right.equalTo(titleTextLimitLabel.snp.left).offset(-15)
        }
        
        titleTextLimitLabel.snp.makeConstraints { make in
            make.bottom.equalTo(titleTextField.snp.bottom)
            make.right.equalToSuperview().offset(-5)
            make.width.equalTo(40)
        }
        
        subTitleTextView.snp.makeConstraints { make in
            make.top.equalTo(titleTextField.snp.bottom).offset(30)
            make.left.equalToSuperview().offset(25)
            make.right.equalTo(subTitleLimitLabel.snp.left).offset(-15)
            make.bottom.lessThanOrEqualToSuperview().offset(-20)
        }
        
        subTitleLimitLabel.snp.makeConstraints { make in
            make.bottom.equalTo(subTitleTextView.snp.bottom)
            make.right.equalToSuperview().offset(-5)
            make.width.equalTo(40)
        }
    }
    
    private func changedTitleTextField(){
        titleTextField.rx
            .text
            .orEmpty
            .bind{ text in
                if text.count > 15{
                    let index = text.index(text.startIndex, offsetBy: 15)
                    self.titleTextField.text = String(text[..<index])
                }
            }.disposed(by: disposeBag)
        
        titleTextField.rx
            .text
            .orEmpty
            .bind{ text in
                let count = min(text.count, 15)
                self.titleTextLimitLabel.text = "\(count)/15"
            }.disposed(by: disposeBag)
    }
    
    private func changedSubTitleTextField(){
        subTitleTextView.rx
            .didBeginEditing
            .bind{ _ in
                if self.subTitleTextView.text == "#해시태그로 채팅방을 소개해 주세요."{
                    self.subTitleTextView.text = ""
                }
                self.subTitleTextView.textColor = .black
            }.disposed(by: disposeBag)
        
        subTitleTextView.rx
            .didEndEditing
            .bind{ _ in
                if self.subTitleTextView.text.count == 0{
                    self.subTitleTextView.text = "#해시태그로 채팅방을 소개해 주세요."
                    self.subTitleTextView.textColor = .lightGray
                    self.subTitleTextView.font = UIFont.systemFont(ofSize: 15, weight: .medium)
                }
            }.disposed(by: disposeBag)
        
        subTitleTextView.rx
            .text
            .orEmpty
            .bind{ text in
                if text.count > 60{
                    let index = text.index(text.startIndex, offsetBy: 60)
                    self.titleTextField.text = String(text[..<index])
                }
                if self.subTitleTextView.textColor != .lightGray{
                    self.subTitleTextView.resolveHashTags()
                }
            }.disposed(by: disposeBag)
        
        subTitleTextView.rx
            .text
            .orEmpty
            .bind{ text in
                if self.subTitleTextView.textColor != .lightGray{
                    let count = min(text.count, 60)
                    self.subTitleLimitLabel.text = "\(count)/60"
                }
            }.disposed(by: disposeBag)
    }
    
    private func setCustomSubTitleTextViewReturnKey(){
        subTitleTextView.rx
            .didChange
            .bind{
                if let text = self.subTitleTextView.text, text.hasSuffix("\n") {
                    self.subTitleTextView.text = text.trimmingCharacters(in: .newlines)
                    self.subTitleTextView.resignFirstResponder()
                }
            }.disposed(by: disposeBag)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        thumnailImage.layer.cornerRadius = thumnailImage.bounds.width / 2
    }
}
