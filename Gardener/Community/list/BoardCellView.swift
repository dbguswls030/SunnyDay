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
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .black
        label.sizeToFit()
        return label
    }()
    
    lazy var contents: UILabel = {
        var label = UILabel()
        label.text = "내...\n\n...용"
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 3
        label.lineBreakMode = .byTruncatingTail
        label.textColor = .black
        label.sizeToFit()
        return label
    }()
    
    lazy var images: UICollectionView = {
        var collectionView = UICollectionView(frame: .init(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: .init())
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
//        self.addSubview(images)
        self.addSubview(date)
        
        categroy.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.top.equalToSuperview().offset(5)
            make.height.equalTo(categroy.intrinsicContentSize.height)
        }
        
        title.snp.makeConstraints { make in
            make.top.equalTo(categroy.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(title.intrinsicContentSize.height)
        }
        
        contents.snp.makeConstraints { make in
            make.top.equalTo(title.snp.bottom).offset(5)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(contents.intrinsicContentSize.height)
        }
        
//        images.snp.makeConstraints { make in
//            make.top.equalTo(contents.snp.bottom).offset(20)
//            make.left.equalToSuperview().offset(10)
//            make.right.equalToSuperview().offset(-10)
//            make.height.equalTo(200)
//        }
        
        date.snp.makeConstraints { make in
            make.top.equalTo(contents.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview().offset(-10)
        }
    }
    
    func getCategoryHeight() -> CGFloat{
        return categroy.intrinsicContentSize.height + 5
    }
    
    func getTitleHeight() -> CGFloat{
        return title.intrinsicContentSize.height + 15
    }
    
    func getContentsHeight() -> CGFloat{
        return 5 + contents.intrinsicContentSize.height
    }
    
    func getDateHeight() -> CGFloat{
        return 15 + date.intrinsicContentSize.height + 10
    }
}
