//
//  Common.swift
//  Gardener
//
//  Created by 유현진 on 2023/06/05.
//

import Foundation
import UIKit

enum BoardCategory: String, CaseIterable{
    case free = "자유"
    case question = "질문/답변"
}

extension UIViewController {
    func hideKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
            action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

class BreakLine: UIView{
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .lightGray
        self.alpha = 0.2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

