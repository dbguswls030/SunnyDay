//
//  MyMessageTableViewCell.swift
//  Gardener
//
//  Created by 유현진 on 3/8/24.
//

import UIKit
import SnapKit

class MyMessageTableViewCell: UITableViewCell {
    
    static let identifier = "MyMessageCell"
    
    private lazy var contentTextView: UITextView = {
        var textView = UITextView()
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.showsVerticalScrollIndicator = false
        textView.showsHorizontalScrollIndicator = false
        textView.backgroundColor = .init(red: 193/255, green: 202/255, blue: 245/255, alpha: 1)
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.textContainerInset = UIEdgeInsets(top: 7, left: 8, bottom: 7, right: 8)
        return textView
    }()
    
    private lazy var timeLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10, weight: .light)
        label.textColor = .systemGray
        return label
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        contentTextView.text = " "
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
    
    func setData(model: ChatMessageModel){
        self.timeLabel.text = model.date.convertDateToCurrentTime()
        self.contentTextView.text = model.message
    }

    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentTextView.layer.cornerRadius = min(contentTextView.bounds.height, contentTextView.bounds.width) * 0.4
    }
}
