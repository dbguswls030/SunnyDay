//
//  Toast.swift
//  Gardener
//
//  Created by 유현진 on 2023/08/18.
//

import Foundation
import UIKit

class Toast{
    // TODO: 최상위 뷰?
    // TODO: 팝업 위치 동적으로 조정(키보드 나와있을 경우, 홈일 경우 등...)
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
