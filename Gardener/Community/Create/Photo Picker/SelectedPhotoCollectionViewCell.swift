//
//  SelectedPhotoCollectionViewCell.swift
//  Gardener
//
//  Created by 유현진 on 2023/06/08.
//

import UIKit
import SnapKit

protocol DeleteImageDelegate: AnyObject{
    func deleteImage(sender: UIButton)
}

class SelectedPhotoCollectionViewCell: UICollectionViewCell {
    
    lazy var imageView: UIImageView = {
        var imageView = UIImageView()
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var deleteButton: UIButton = {
        var button = UIButton()
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.imageView?.tintColor = .black
        button.backgroundColor = .white
        button.clipsToBounds = true
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        addSubview(deleteButton)
        
        imageView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(5)
            make.trailing.bottom.equalToSuperview().offset(-5)
        }

        deleteButton.snp.makeConstraints { make in
            make.width.height.equalTo(20)
            make.centerY.equalTo(imageView.snp.top)
            make.centerX.equalTo(imageView.snp.right)
        }
        deleteButton.layer.cornerRadius = 10
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
            self.imageView.layer.cornerRadius = 5
        }
    }
}
