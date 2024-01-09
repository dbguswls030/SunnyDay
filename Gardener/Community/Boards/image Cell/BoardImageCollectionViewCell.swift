//
//  BoardImageCollectionViewCell.swift
//  Gardener
//
//  Created by 유현진 on 2023/09/21.
//

import UIKit
import SnapKit
import Kingfisher

class BoardImageCollectionViewCell: UICollectionViewCell {
    
    var imageView: UIImageView = {
        var imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 5
        imageView.clipsToBounds = true
        imageView.image = nil
        return imageView
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    func setImageUrl(url: String){
        imageView.setImageView(url: url)
    }
    
    func initUI(){
        self.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
