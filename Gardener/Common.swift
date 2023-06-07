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
