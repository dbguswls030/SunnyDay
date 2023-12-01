//
//  BoardCellView.swift
//  Gardener
//
//  Created by 유현진 on 2023/08/31.
//

import UIKit
import SnapKit

class BoardCellView: UIView {

    lazy var categroy: UILabel = {
        var label = UILabel()
        label.text = "카테고리"
        label.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        label.sizeToFit()
        label.textColor = .black
        return label
    }()
    
    lazy var title: UILabel = {
        var label = UILabel()
        label.text = "제목"
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .black
        label.sizeToFit()
        return label
    }()
    
    lazy var contents: UILabel = {
        var label = UILabel()
        label.text = "내"
        label.font = UIFont.systemFont(ofSize: 15)
        label.numberOfLines = 3
        label.lineBreakMode = .byTruncatingTail
        label.textColor = .black
        label.sizeToFit()
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
    
    lazy var date: UILabel = {
        var label = UILabel()
        label.text = "날짜"
        label.font = UIFont.systemFont(ofSize: 10, weight: .ultraLight)
        label.sizeToFit()
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
        self.addSubview(categroy)
        self.addSubview(title)
        self.addSubview(contents)
        self.addSubview(date)
        
        categroy.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(20)
            make.height.equalTo(categroy.intrinsicContentSize.height)
        }
        
        title.snp.makeConstraints { make in
            make.top.equalTo(categroy.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(title.intrinsicContentSize.height)
        }
        
        contents.snp.makeConstraints { make in
            make.top.equalTo(title.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
//            make.height.equalTo(contents.intrinsicContentSize.height)
        }
        
        date.snp.makeConstraints { make in
            make.top.equalTo(contents.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.bottom.equalToSuperview().offset(-20)
        }
    }

    func initImageColletionViewLayout(){
        self.addSubview(imageCollectionView)
        imageCollectionView.snp.makeConstraints { make in
            make.top.equalTo(contents.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(150)
        }
    
        date.snp.remakeConstraints { make in
            make.top.equalTo(imageCollectionView.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    func prepareReuseInitUI(){
        imageCollectionView.removeFromSuperview()
        date.snp.remakeConstraints { make in
            make.top.equalTo(contents.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
}
