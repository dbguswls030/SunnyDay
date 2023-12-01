//
//  CommentWriteView.swift
//  Gardener
//
//  Created by 유현진 on 2023/11/29.
//

import UIKit
import SnapKit

class CommentWriteView: UIView, UITextViewDelegate{
    
    private lazy var topBreakLine: BreakLine = {
        return BreakLine()
    }()
    
    private lazy var commentTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.backgroundColor = .systemGray6
        textView.layer.cornerRadius = 13
        textView.delegate = self
        textView.text = "댓글을 입력해 주세요."
        textView.textColor = .lightGray
        textView.contentInset = .init(top: 0, left: 6, bottom: 0, right: 6)
        textView.isScrollEnabled = false
        return textView
    }()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton()
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(systemName: "arrow.right.circle.fill", withConfiguration: UIImage.SymbolConfiguration.init(pointSize: 20))
        button.configuration = configuration
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initUI(){
        self.backgroundColor = .white
        
        self.addSubview(topBreakLine)
        self.addSubview(commentTextView)
        self.addSubview(sendButton)
        
        topBreakLine.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        sendButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-5)
            make.bottom.equalToSuperview()
            make.height.width.equalTo(50)
        }
        
        commentTextView.snp.makeConstraints { make in
            make.top.equalTo(topBreakLine.snp.bottom).offset(8)
            make.bottom.equalToSuperview().offset(-8)
            make.left.equalToSuperview().offset(20)
            make.right.equalTo(sendButton.snp.left)
            make.height.equalTo(50 - (0.5 + 16))
        }
        
    }
}
extension CommentWriteView{
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty{
            textView.textColor = .lightGray
            textView.text = "댓글을 입력해 주세요."
        }
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray{
            textView.text = ""
            textView.textColor = .black
        }
    }
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: self.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        textView.constraints.forEach { constraint in
            if estimatedSize.height >= 130{
                commentTextView.isScrollEnabled = true
            }else{
                self.sizeToFit()
                commentTextView.isScrollEnabled = false
                if constraint.firstAttribute == .height{
                    constraint.constant = estimatedSize.height
                }
            }
        }
    }
    
}
