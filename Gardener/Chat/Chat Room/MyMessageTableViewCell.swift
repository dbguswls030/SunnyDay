//
//  MyMessageTableViewCell.swift
//  Gardener
//
//  Created by 유현진 on 3/8/24.
//

import UIKit
import SnapKit
import RxSwift

class MyMessageTableViewCell: UITableViewCell{
    
    static let identifier = "MyMessageCell"
    
    var menuInteraction: UIContextMenuInteraction!
    
    var disposeBag = DisposeBag()
    
    lazy var messageLabel: MessageLabel = {
        var label = MessageLabel()
        label.backgroundColor = .init(red: 193/255, green: 202/255, blue: 245/255, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 14)
        label.clipsToBounds = true
        label.numberOfLines = 0
        label.isUserInteractionEnabled = true
        label.layer.cornerRadius = 5
        return label
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
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        messageLabel.text = " "
        timeLabel.text = " "
    }
    
    func addMenuInteraction(vc: UIContextMenuInteractionDelegate){
        menuInteraction = .init(delegate: vc)
        messageLabel.addInteraction(menuInteraction)
    }
    
    private func initUI(){
        self.backgroundColor = .clear
        let clearView = UIView()
        clearView.backgroundColor = .clear
        self.selectedBackgroundView = clearView
        self.contentView.addSubview(messageLabel)
        self.addSubview(timeLabel)
 
        messageLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.right.equalToSuperview().offset(-8)
            make.width.lessThanOrEqualToSuperview().offset(-110).priority(.high)
            make.bottom.equalToSuperview().offset(-5)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.bottom.equalTo(messageLabel.snp.bottom)
            make.right.equalTo(messageLabel.snp.left).offset(-3)
        }
    }
    
    func setData(model: ChatMessageModel){
        self.timeLabel.text = model.date.convertDateToCurrentTime()
        self.messageLabel.text = model.message
        self.messageLabel.sizeToFit()
    }
}
