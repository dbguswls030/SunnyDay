//
//  CommentCollectionViewCell.swift
//  Gardener
//
//  Created by 유현진 on 12/3/23.
//

import UIKit
import SnapKit

class CommentCollectionViewCell: UICollectionViewCell {
    private lazy var profileImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "umZza"))
        imageView.layer.cornerRadius = 20
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var nickNameLabel: UILabel = {
        let label = UILabel()
        label.tintColor = .black
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.text = "어무기"
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.tintColor = .lightGray
        label.font = .systemFont(ofSize: 12, weight: .light)
        return label
    }()
    
    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.tintColor = .black
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.sizeToFit()
        return label
    }()
    
    override func prepareForReuse() {
        profileImage.image = nil
        nickNameLabel.text = ""
        dateLabel.text = ""
        contentLabel.text = ""
        profileImage.snp.updateConstraints { make in
            make.left.equalToSuperview().offset(10)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initUI(){
        self.addSubview(profileImage)
        self.addSubview(nickNameLabel)
        self.addSubview(dateLabel)
        self.addSubview(contentLabel)
        
        profileImage.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(10)
            make.width.height.equalTo(45)
        }
        
        nickNameLabel.snp.makeConstraints { make in
            make.left.equalTo(profileImage.snp.right).offset(12)
            make.top.equalTo(profileImage.snp.top).offset(5)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.left.equalTo(profileImage.snp.right).offset(12)
            make.bottom.equalTo(profileImage.snp.bottom).offset(-5)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.left.equalTo(profileImage.snp.right).offset(12)
            make.top.equalTo(profileImage.snp.bottom).offset(5)
            make.right.equalToSuperview().offset(10)
            make.bottom.equalToSuperview()
        }
    }
    func setContent(content: String){
        self.contentLabel.text = content
        self.contentLabel.sizeToFit()
    }
    
    func setDate(date: Date){
        // TODO: 날짜 케이스, 분, 시간, 일
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let formattedDate = dateFormatter.string(from: date)
        self.dateLabel.text = formattedDate
    }
    
    func getContentHeight() -> CGFloat{
        return contentLabel.frame.height
    }
    
    func updateConstraintsWithDept(){
        profileImage.snp.updateConstraints { make in
            make.left.equalToSuperview().offset(10 + 45 + 12)
        }
    }
}
