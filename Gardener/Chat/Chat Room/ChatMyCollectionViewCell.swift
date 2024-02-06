//
//  ChatCollectionViewCell.swift
//  Gardener
//
//  Created by 유현진 on 1/31/24.
//

import UIKit
import SnapKit
class ChatMyCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "MyChatCell"
    
    private lazy var contentTextView: UITextView = {
        var textView = UITextView()
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.backgroundColor = .green
        textView.font = UIFont.systemFont(ofSize: 14)
        return textView
    }()
    
    private lazy var timeLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10, weight: .light)
        label.textColor = .systemGray
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
        contentTextView.text = ""
    }
    
    private func initUI(){
        self.backgroundColor = .clear
        
        self.addSubview(contentTextView)
        self.addSubview(timeLabel)
        
        contentTextView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.right.equalToSuperview().offset(-8)
            make.width.lessThanOrEqualToSuperview().offset(-110).priority(.high)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.bottom.equalTo(contentTextView.snp.bottom)
            make.right.equalTo(contentTextView.snp.left).offset(-3)
        }
    }
    
    
    func setData(model: ChatModel){
        self.timeLabel.text = model.date.convertDateToCurrentTime()
        self.contentTextView.text = model.message
    }

    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentTextView.layer.cornerRadius = min(contentTextView.bounds.height, contentTextView.bounds.width) * 0.1
    }
    
    func getTextViewHeight() -> CGFloat{
        return contentTextView.intrinsicContentSize.height
    }
}
