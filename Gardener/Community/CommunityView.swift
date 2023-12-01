//
//  CommunityView.swift
//  Gardener
//
//  Created by 유현진 on 2023/08/31.
//

import UIKit
import SnapKit

class CommunityView: UIView {
    
    lazy var boardCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        // TODO: 색상 고르기
        collectionView.backgroundColor = .green
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
    
    func initUI(){
        self.backgroundColor = .white
        
        self.addSubview(boardCollectionView)
        boardCollectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
