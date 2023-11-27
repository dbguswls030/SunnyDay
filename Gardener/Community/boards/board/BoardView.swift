//
//  BoardView.swift
//  Gardener
//
//  Created by 유현진 on 2023/11/07.
//

import UIKit
import SnapKit

class BoardView: UIView {
    
    private lazy var navigationBottomBreakLine: BreakLine = {
        return BreakLine()
    }()
    
    private lazy var boardTitleLabel: UILabel = {
        let label = UILabel()
        label.tintColor = .black
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.text = "고구마를 먹었습니다."
        return label
    }()
    
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
        label.text = "작성시간"
        label.tintColor = .lightGray
        label.font = .systemFont(ofSize: 12, weight: .light)
        return label
    }()
    
    private lazy var writerInfoBreakLine: BreakLine = {
        return BreakLine()
    }()
    
    private lazy var boardContent: UILabel = {
        let label = UILabel()
        label.text = "고구마근기를 해야겠어요~"
        label.tintColor = .black
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        // TODO: 여러 줄
        return label
    }()
    
    lazy var imageCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = .zero
        var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.decelerationRate = .fast 
        return collectionView
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
        self.addSubview(navigationBottomBreakLine)
        self.addSubview(boardTitleLabel)
        self.addSubview(profileImage)
        self.addSubview(nickNameLabel)
        self.addSubview(dateLabel)
        self.addSubview(writerInfoBreakLine)
        
        self.addSubview(boardContent)
        
        navigationBottomBreakLine.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        boardTitleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.top.equalTo(navigationBottomBreakLine.snp.bottom).offset(20)
        }
        
        profileImage.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.top.equalTo(boardTitleLabel.snp.bottom).offset(20)
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
        
        writerInfoBreakLine.snp.makeConstraints { make in
            make.top.equalTo(profileImage.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        boardContent.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(writerInfoBreakLine.snp.bottom).offset(20)
        }
    }
    
    func initImageCollectionView(){
        self.addSubview(imageCollectionView)
        
        imageCollectionView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(boardContent.snp.bottom).offset(20)
            make.height.equalTo(150)
        }
    }
    func setTitle(title: String){
        self.boardTitleLabel.text = title
    }
    
    func setContents(contents: String){
        self.boardContent.text = contents
    }
    
    func setDate(date: Date){
        // TODO: 날짜 케이스, 분, 시간, 일
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let formattedDate = dateFormatter.string(from: date)
        self.dateLabel.text = formattedDate
    }
}