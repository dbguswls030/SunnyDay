//
//  MyViewController.swift
//  Gardener
//
//  Created by 유현진 on 2023/03/28.
//

import UIKit
import SnapKit

class MyViewController: UIViewController, UIContextMenuInteractionDelegate, UITextViewDelegate {
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .lightGray
        textView.text = "1123123514571023471207834"
        textView.isScrollEnabled = false
        textView.isEditable = false
        return textView
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton()
        button.setTitle("asdasdassdasdasdasd", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    var menuInteraction: UIContextMenuInteraction?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .yellow
        initUI()
        hideKeyboardWhenTouchUpBackground()
        // Do any additional setup after loading the view.
        addMenuInteraction()
        
    }
    private func initUI(){
        self.view.addSubview(textView)
        self.view.addSubview(button)
        textView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(200)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        button.snp.makeConstraints { make in
            make.top.equalTo(textView.snp.bottom)
            make.left.equalToSuperview()
        }
    }
    
    private func addMenuInteraction(){
        menuInteraction = .init(delegate: self)
        textView.addInteraction(menuInteraction!)
        button.addInteraction(menuInteraction!)
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(actionProvider:  { [unowned self] suggestedActions in
            let copyAction = UIAction(title: "복사", image: UIImage(systemName: "doc.on.doc")) { _ in
                print("복사하기")
            }
            let pasteAction = UIAction(title: "붙혀넣기",image: UIImage(systemName: "doc.on.clipboard")) { _ in
                print("붙혀넣기")
            }
            let shareAction = UIAction(title: "공유",image: UIImage(systemName: "square.and.arrow.up")) { _ in
                print("공유하기")
            }
            let menu = UIMenu(preferredElementSize: .large, children: suggestedActions + [copyAction, pasteAction, shareAction])

            return menu
            
        })
    }
}
