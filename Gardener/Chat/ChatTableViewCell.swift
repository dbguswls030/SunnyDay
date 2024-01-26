//
//  ChatTableViewCell.swift
//  Gardener
//
//  Created by 유현진 on 1/26/24.
//

import UIKit
import SnapKit

class ChatTableViewCell: UITableViewCell {

    private lazy var chatTitleLabel: UILabel = {
        var label = UILabel()
        label.text = "123"
        label.textColor = .black
        return label
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        chatTitleLabel.text = ""
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func initUI(){
        backgroundColor = .systemBackground
        self.addSubview(chatTitleLabel)
        
        chatTitleLabel.snp.makeConstraints { make in
            make.centerY.centerX.equalToSuperview()
        }
    }
    
    func setChatTitle(chatTitle: String){
        self.chatTitleLabel.text = chatTitle
    }
}
