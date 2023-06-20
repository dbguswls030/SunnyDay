//
//  SelectedPhotoCollectionViewCell.swift
//  Gardener
//
//  Created by 유현진 on 2023/06/08.
//

import UIKit
import SnapKit
class SelectedPhotoCollectionViewCell: UICollectionViewCell {
    
    lazy var imageView: UIImageView = {
       return UIImageView()
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateImage(image: UIImage){
        DispatchQueue.main.async {
            self.imageView.image = image
            self.imageView.layer.cornerRadius = self.imageView.frame.width/3
        }
    }
}
