//
//  CreateBoardViewController.swift
//  Gardener
//
//  Created by 유현진 on 2023/05/28.
//

import UIKit
import SnapKit

// TODO: 사진 추가 기능
// TODO: 내용 글자 제한 수

class CreateBoardViewController: UIViewController {
    
    private final let LEADINGTRAIINGOFFSET = 15
    
    private lazy var topBreakLine: BreakLine = {
       return BreakLine()
    }()
    
    private lazy var scrollView: UIScrollView = {
        return UIScrollView()
    }()
    
    private lazy var titleObjcetLabel: UILabel = {
        var label = UILabel()
        label.text = "카테고리를 선택해 주세요."
        label.font = .systemFont(ofSize: 17)
        return label
    }()
    
    private lazy var titleContentBreakLine: BreakLine = {
        return BreakLine()
    }()
    
    private lazy var titleObjectButton: UIButton = {
        var button = UIButton()
        button.setImage(UIImage(systemName: "chevron.forward"), for: .normal)
        button.tintColor = .black
        button.contentHorizontalAlignment = .trailing
        button.addTarget(self, action: #selector(showCategoryList), for: .touchUpInside)
        return button
    }()
    
    private lazy var contentTextView: UITextView = {
        var textView = UITextView()
        textView.isScrollEnabled = false
        textView.font = .systemFont(ofSize: 16)
        textView.text = "내용을 입력해 주세요."
        textView.textColor = .lightGray
        return textView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationBar()
        initUI()
        hideKeyboard()
    }
    
    private func initNavigationBar(){
        self.navigationItem.title = "글쓰기"
        self.navigationItem.setRightBarButton(UIBarButtonItem(image: UIImage(systemName: "arrow.up"), style: .done, target: self, action: #selector(showCategoryList)), animated: true)
        self.navigationItem.rightBarButtonItem?.tintColor = .black
    }
    
    private func initUI(){
        self.view.backgroundColor = .white
        
        self.view.addSubview(topBreakLine)
        self.view.addSubview(scrollView)
        self.scrollView.addSubview(titleObjcetLabel)
        self.scrollView.addSubview(titleObjectButton)
        self.scrollView.addSubview(titleContentBreakLine)
        self.scrollView.addSubview(contentTextView)
        
        topBreakLine.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.trailing.leading.equalToSuperview()
            make.height.equalTo(1)
        }
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(topBreakLine.snp.bottom)
            make.trailing.leading.equalToSuperview()
            make.bottom.equalTo(self.view.keyboardLayoutGuide.snp.top)
        }
        
        titleObjcetLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(LEADINGTRAIINGOFFSET+5)
            make.trailing.equalToSuperview().offset(-LEADINGTRAIINGOFFSET)
            make.top.equalToSuperview()
            make.height.equalTo(60)
        }
        
        titleObjectButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(LEADINGTRAIINGOFFSET+5)
            make.trailing.equalToSuperview().offset(-LEADINGTRAIINGOFFSET)
            make.top.equalToSuperview()
            make.height.equalTo(60)
        }
        
        titleContentBreakLine.snp.makeConstraints { make in
            make.top.equalTo(titleObjcetLabel.snp.bottom)
            make.leading.equalToSuperview().offset(LEADINGTRAIINGOFFSET)
            make.trailing.equalToSuperview().offset(-LEADINGTRAIINGOFFSET)
            make.height.equalTo(1)
        }
        
        contentTextView.snp.makeConstraints { make in
            make.top.equalTo(titleContentBreakLine.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(LEADINGTRAIINGOFFSET)
            make.trailing.equalToSuperview().offset(-LEADINGTRAIINGOFFSET)
            make.bottom.equalToSuperview()
            make.width.equalTo(scrollView.snp.width).offset(-LEADINGTRAIINGOFFSET * 2)
        }
        contentTextView.delegate = self
    }
    
    @objc private func showCategoryList(){
        let vc = CategoryViewController()
        vc.sheetPresentationController?.detents = [.medium()]
        vc.sheetPresentationController?.preferredCornerRadius = 30
        vc.delegate = self
        self.present(vc, animated: true)
    }
}

extension CreateBoardViewController: UITextViewDelegate{
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
}

extension CreateBoardViewController: SendCategoryDelegate{
    func changeCategory(category: String) {
        self.titleObjcetLabel.text = category
    }
}
