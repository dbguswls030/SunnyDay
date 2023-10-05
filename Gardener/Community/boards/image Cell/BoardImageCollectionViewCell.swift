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
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 5
        imageView.clipsToBounds = true
        return imageView
    }()
    
    
    func setImage(url: String){
        self.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        FirebaseStorageManager.downloadBoardImages(url: url) { image in
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }
    }
}
