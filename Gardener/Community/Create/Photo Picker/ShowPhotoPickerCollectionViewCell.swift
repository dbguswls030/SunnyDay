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
        button.imageView?.preferredSymbolConfiguration = .init(weight: .thin)
        button.imageView?.tintColor = .green
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
