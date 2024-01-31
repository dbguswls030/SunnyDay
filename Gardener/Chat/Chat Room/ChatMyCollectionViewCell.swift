//
//  ChatCollectionViewCell.swift
//  Gardener
//
//  Created by 유현진 on 1/31/24.
//

import UIKit
import SnapKit
class ChatMyCollectionViewCell: UICollectionViewCell {
    private lazy var contentTextView: UITextView = {
        var textView = UITextView()
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.backgroundColor = .green
        return textView
    }()
    
    private lazy var timeLabel: UILabel = {
        var label = UILabel()
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        
    }
    
    private func initUI(){
        self.backgroundColor = .clear
        
        self.addSubview(contentTextView)
        self.addSubview(timeLabel)
        
        contentTextView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.right.equalToSuperview().offset(-5)
            make.left.lessThanOrEqualToSuperview().offset(40)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.bottom.equalTo(contentTextView.snp.bottom)
            make.right.equalTo(contentTextView.snp.left).offset(-3)
        }
    }
}
