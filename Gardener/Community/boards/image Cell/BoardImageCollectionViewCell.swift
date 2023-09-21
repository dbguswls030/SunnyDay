//
//  BoardImageCollectionViewCell.swift
//  Gardener
//
//  Created by 유현진 on 2023/09/21.
//

import UIKit
import SnapKit

class BoardImageCollectionViewCell: UICollectionViewCell {
    lazy var imageView: UIImageView = {
        var imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 5
        return imageView
    }()
    
    
    func setImage(image: UIImage){
        self.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        DispatchQueue.main.async {
            self.imageView.image = image
        }
    }
}
