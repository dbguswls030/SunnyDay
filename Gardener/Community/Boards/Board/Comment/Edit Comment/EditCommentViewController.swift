//
//  EditCommentViewController.swift
//  Gardener
//
//  Created by 유현진 on 1/12/24.
//

import UIKit
import SnapKit

class EditCommentViewController: UIViewController {
    
    var boardDocumentId: String?
    var model: CommentModel?
    
    weak var delegate: DelegateEditComment?
    
    private lazy var topBreakLine: BreakLine = {
        return BreakLine()
    }()
    private lazy var scrollView: UIScrollView = {
        return UIScrollView()
    }()
    internal lazy var contentTextView: UITextView = {
        var textView = UITextView()
        textView.isScrollEnabled = false
        textView.font = .systemFont(ofSize: 16)
        textView.text = "내용을 입력해 주세요."
        textView.textColor = .lightGray
        textView.delegate = self
        return textView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationBar()
        initUI()
        // Do any additional setup after loading the view.
    }
    private func initUI(){
        self.view.backgroundColor = .systemBackground
        self.view.addSubview(topBreakLine)
        self.view.addSubview(scrollView)
        self.scrollView.addSubview(contentTextView)
        
        topBreakLine.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(topBreakLine.snp.bottom).offset(10)
            make.bottom.equalTo(self.view.keyboardLayoutGuide.snp.top).offset(-10)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
        }
        contentTextView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-10)
        }
    }
    
    private func initNavigationBar(){
        self.title = "댓글 수정"
        self.navigationItem.setRightBarButton(.init(title: "수정", image: nil, target: self, action: #selector(editComment)), animated: true)
        self.navigationItem.rightBarButtonItem?.tintColor = .black
    }
    
    @objc private func editComment(){
        guard let model = model else { return }
        dismissKeyboard()
        showActivityIndicator(alpha: 0.0)
        FirebaseFirestoreManager.shared.updateComment(boardDocumentId: boardDocumentId!, commentDocumentId: model.documentId!, content: self.contentTextView.text) { [weak self] in
            guard let self = self else {return}
            self.delegate?.endEditComment()
            self.hideActivityIndicator(alpha: 0.0)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func setData(){
        guard let model = model else {return}
        contentTextView.text = model.content
        self.contentTextView.textColor = .black
    }
    
}
extension EditCommentViewController: UITextViewDelegate{
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty{
            textView.textColor = .lightGray
            textView.text = "내용을 입력해 주세요."
        }
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray{
            textView.text = ""
            textView.textColor = .black
        }
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let contentText = textView.text ?? ""
        guard let stringRange = Range(range, in: contentText) else { return false }
        let convertText = contentText.replacingCharacters(in: stringRange, with: text)
        if contentTextView.text!.count > 300{
            return false
        }
        return true
    }
}
