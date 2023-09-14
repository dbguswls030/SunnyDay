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
        label.sizeToFit()
        label.textColor = .black
        return label
    }()
    
    lazy var date: UILabel = {
        var label = UILabel()
        return label
    }()
    
    lazy var contents: UILabel = {
        var label = UILabel()
        label.numberOfLines = 4
        label.lineBreakMode = .byTruncatingTail
        label.textColor = .black
        return label
    }()
    
    lazy var images: UICollectionView = {
        var collectionView = UICollectionView(frame: .init(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: .init())
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
        self.addSubview(categroy)
        self.addSubview(contents)
//        self.addSubview(images)
        
        categroy.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.top.equalToSuperview().offset(5)
        }
        
        contents.snp.makeConstraints { make in
            make.top.equalTo(categroy.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
        }
        
//        images.snp.makeConstraints { make in
//            make.top.equalTo(contents.snp.bottom).offset(20)
//            make.left.equalToSuperview().offset(10)
//            make.right.equalToSuperview().offset(-10)
//            make.height.equalTo(200)
//        }
    }
    
    func getCategoryHeight() -> CGFloat{
        return 5
    }
    
    func getContentsHeight() -> CGFloat{
        return 15
    }
}
