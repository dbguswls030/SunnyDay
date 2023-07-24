//
//  SignUpViewController.swift
//  Gardener
//
//  Created by 유현진 on 2023/07/17.
//

import UIKit
import SnapKit

class SignUpViewController: UIViewController {

    private lazy var signView: SignUpView = {
        return SignUpView()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initUI()
    }
    
    private func initUI(){
        self.view.addSubview(signView)
        
        signView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
