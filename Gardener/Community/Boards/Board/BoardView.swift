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
        return label
    }()
    
    private lazy var profileImage: UIImageView = {
        let imageView = UIImageView()
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
        label.textColor = .lightGray
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
    
    private lazy var viewCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 8, weight: .light)
        label.tintColor = .lightGray
        label.text = "0 명이 이 글을 봤어요"
        return label
    }()
    
    lazy var likeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "suit.heart", withConfiguration: UIImage.SymbolConfiguration.init(pointSize: 14, weight: .semibold)), for: .normal)
        button.setImage(UIImage(systemName: "suit.heart.fill", withConfiguration: UIImage.SymbolConfiguration.init(pointSize: 14, weight: .semibold)), for: .selected)
        button.tintColor = .lightGray
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 1.5
        button.layer.borderColor = UIColor.systemGray5.cgColor
//        button.addTarget(self, action: #selector(toggleLikeButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var likeImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "heart", withConfiguration: UIImage.SymbolConfiguration.init(pointSize: 8, weight: .semibold)))
        imageView.tintColor = .green
        return imageView
    }()
    
    private lazy var likeCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .lightGray
        return label
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
        self.addSubview(likeButton)
        self.addSubview(likeImageView)
        self.addSubview(likeCountLabel)
//        self.addSubview(viewCountLabel)
        
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
        boardTitleLabel.sizeToFit()
        
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
        
        likeButton.snp.makeConstraints { make in
            make.top.equalTo(boardContent.snp.bottom).offset(30)
            make.left.equalToSuperview().offset(20)
            make.height.equalTo(40)
            make.width.equalTo(50)
        }
        
        likeCountLabel.snp.makeConstraints { make in
            make.centerY.equalTo(likeButton.snp.centerY)
            make.right.equalToSuperview().offset(-20)
        }
        
        likeImageView.snp.makeConstraints { make in
            make.centerY.equalTo(likeButton.snp.centerY)
            make.right.equalTo(likeCountLabel.snp.left).offset(-5)
            make.height.width.equalTo(20)
        }
        
//        viewCountLabel.snp.makeConstraints { make in
//            make.top.equalTo(boardContent.snp.bottom).offset(20)
//            make.left.equalToSuperview().offset(20)
//        }
    }
    
    func initImageCollectionView(){
        self.addSubview(imageCollectionView)
        
        imageCollectionView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(boardContent.snp.bottom).offset(20)
            make.height.equalTo(150)
        }
        
        likeButton.snp.remakeConstraints { make in
            make.top.equalTo(imageCollectionView.snp.bottom).offset(30)
            make.left.equalToSuperview().offset(20)
            make.height.equalTo(40)
            make.width.equalTo(50)
        }
        
//        viewCountLabel.snp.remakeConstraints { make in
//            make.top.equalTo(imageCollectionView.snp.bottom).offset(20)
//            make.left.equalToSuperview().offset(20)
//        }
    }
    
    func toggleLikeButton(){
        self.likeButton.isSelected.toggle()
        if self.likeButton.isSelected{
            self.likeButton.tintColor = .green
            self.likeButton.layer.borderColor = UIColor.green.cgColor
        }else{
            self.likeButton.tintColor = .lightGray
            self.likeButton.layer.borderColor = UIColor.systemGray5.cgColor
        }
    }
    
    func setLikeButton(isLike: Bool){
        if isLike == true{
            DispatchQueue.main.async {
                self.likeButton.isSelected = true
                self.likeButton.tintColor = .green
                self.likeButton.layer.borderColor = UIColor.green.cgColor
            }
        }else{
            DispatchQueue.main.async {
                self.likeButton.isSelected = false
                self.likeButton.tintColor = .lightGray
                self.likeButton.layer.borderColor = UIColor.systemGray5.cgColor
            }
        }
    }
    
    func setTitle(title: String){
        self.boardTitleLabel.text = title
    }
    
    func setContents(contents: String){
        self.boardContent.text = contents
    }
    
    func setNickName(nickName: String){
        self.nickNameLabel.text = nickName
    }
    
    func setProfileImage(profileImageURL: String){
        self.profileImage.setImageView(url: profileImageURL)
    }
    
    func setDate(date: Date){
        self.dateLabel.text = date.convertDateToTime()
    }
    
    func setLikeCount(likeCount: Int){
        self.likeCountLabel.text = "\(likeCount)"
    }
}
