//
//  BoardImageCollectionViewCell.swift
//  Gardener
//
//  Created by 유현진 on 2023/09/21.
//

import UIKit
import SnapKit

class BoardImageCollectionViewCell: UICollectionViewCell {
    var imageUrl: String?
    
    private var imageLoadingTask: DispatchWorkItem?
    
    lazy var imageView: UIImageView = {
        var imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 5
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageLoadingTask?.cancel()
        imageView.image = nil
    }
    
    func imageLoading(){
        self.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        imageView.image = nil
        imageLoadingTask?.cancel()
        
        let task = DispatchWorkItem { [weak self] in
            if let url = self?.imageUrl {
                // 이미지를 비동기적으로 로드하고 설정
                // 여기에서 이미지를 비동기로 다운로드 및 설정
                FirebaseStorageManager.downloadBoardImages(url: url) { image in
                    DispatchQueue.main.async {
                        self?.imageView.image = image
                    }
                }
            }
        }

        
        imageLoadingTask = task
        DispatchQueue.global().async(execute: task)
    }
    
    func setImageUrl(url: String){
        self.imageUrl = url
        imageLoading()
    }
    func initUI(){
        self.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
//    func setImage(){
//        FirebaseStorageManager.downloadBoardImages(url: self.imageUrl!) { image in
//            DispatchQueue.main.async {
//                self.imageView.image = image
//            }
//        }
//    }
}
