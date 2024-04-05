//
//  ReplyNoticeView.swift
//  Gardener
//
//  Created by 유현진 on 12/11/23.
//

import UIKit
import SnapKit

class ReplyNoticeView: UIView {

    private lazy var topBreakLine: BreakLine = {
        return BreakLine()
    }()
    
    private lazy var noticeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        return label
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .black
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
        self.backgroundColor = .systemBackground
        self.addSubview(topBreakLine)
        self.addSubview(noticeLabel)
        self.addSubview(cancelButton)
        
        topBreakLine.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        noticeLabel.snp.makeConstraints { make in
            make.top.equalTo(topBreakLine.snp.bottom).offset(10)
            make.bottom.equalToSuperview().offset(-10)
            make.left.equalToSuperview().offset(20)
            make.right.equalTo(cancelButton.snp.left).offset(-10)
        }
        
        cancelButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
            make.right.equalToSuperview().offset(-15)
        }
    }
    
    func setNoticeLabel(nickName: String){
        self.noticeLabel.text = "\(nickName) 님에게 답글 작성 중"
    }
}
