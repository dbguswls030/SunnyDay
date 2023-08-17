//
//  Toast.swift
//  Gardener
//
//  Created by 유현진 on 2023/08/18.
//

import Foundation
import UIKit

class Toast{
    func showToast(view: UIView, message: String){
        let toastLabel = UILabel()
        toastLabel.text = message
        toastLabel.backgroundColor = .black
        toastLabel.textColor = .white
        toastLabel.font = .systemFont(ofSize: 14)
        toastLabel.layer.cornerRadius = 4
        toastLabel.clipsToBounds = true
        toastLabel.textAlignment = .center
        
        view.addSubview(toastLabel)
        toastLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(40)
            make.bottom.equalToSuperview().offset(-100)
        }
        
        UIView.animate(withDuration: 3.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}
