//
//  InputBarView.swift
//  Gardener
//
//  Created by 유현진 on 1/31/24.
//

import UIKit
import SnapKit

class InputBarView: UIView {

    private lazy var topBreakLine: BreakLine = {
        return BreakLine()
    }()
    
    lazy var inputTextView: UITextView = {
        var textView = UITextView()
        textView.backgroundColor = .systemGray6
        textView.contentInset = .init(top: 0, left: 4, bottom: 0, right: 4)
        textView.textContainerInset = .init(top: 8, left: 4, bottom: 8, right: 4)
        textView.alignTextVerticallyInContainer()
        textView.isScrollEnabled = false
        textView.font = UIFont.systemFont(ofSize: 15)
        return textView
    }()
    
    lazy var sendButton: UIButton = {
        var button = UIButton()
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(systemName: "arrow.right.circle.fill", withConfiguration: UIImage.SymbolConfiguration.init(pointSize: 20))
        button.configuration = configuration
        button.isEnabled = false
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
        backgroundColor = .systemBackground
        
        self.addSubview(topBreakLine)
        self.addSubview(inputTextView)
        self.addSubview(sendButton)
        
        topBreakLine.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(0.5)
        }

        inputTextView.snp.makeConstraints { make in
            make.top.equalTo(topBreakLine.snp.bottom).offset(6)
            make.left.equalToSuperview().offset(20)
            make.right.equalTo(sendButton.snp.left).offset(-8)
            make.bottom.equalToSuperview().offset(-6)
            make.height.equalTo(45 - 0.5 - 12)
        }
        
        sendButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-5)
            make.bottom.equalToSuperview()
            make.width.height.equalTo(45)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        inputTextView.layer.cornerRadius = inputTextView.frame.size.width * 0.05
    }
}
