//
//  ShowPhotoPickerCollectionViewCell.swift
//  Gardener
//
//  Created by 유현진 on 2023/06/08.
//

import UIKit
import SnapKit

class ShowPhotoPickerCollectionViewCell: UICollectionViewCell {
    
    lazy var pickerButton: UIButton = {
        var button = UIButton()
        button.setImage(UIImage(systemName: "plus.square.dashed"), for: .normal)
//        button.imageView?.preferredSymbolConfiguration = .init(pointSize: 25, weight: .thin, scale: .large)
        button.imageView?.tintColor = .green
        button.imageView?.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        button.imageEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(pickerButton)
        
        pickerButton.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
    
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
