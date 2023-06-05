//
//  CreateBoardViewController.swift
//  Gardener
//
//  Created by 유현진 on 2023/05/28.
//

import UIKit
import SnapKit
class CreateBoardViewController: UIViewController {
    
    // 내용, 분류, 사진
    // MARK: TODO
    // 키보드 제어
    // - 키보드 올라오면 contentView 동적 높이 조절
    // - 다른 곳 터치하면 키보드 숨기기
    
    final let LEADINGTRAIINGOFFSET = 15
    
    lazy var scrollView: UIScrollView = {
        var scrollView = UIScrollView()
        return scrollView
    }()
    
    lazy var titleObjcetLabel: UILabel = {
        var label = UILabel()
        label.text = "카테고리를 선택해 주세요."
        label.font = .systemFont(ofSize: 17)
        return label
    }()
    
    lazy var titleObjectButton: UIButton = {
        var button = UIButton()
        button.setImage(UIImage(systemName: "chevron.forward"), for: .normal)
        button.tintColor = .black
        button.contentHorizontalAlignment = .trailing
        return button
    }()
    
    lazy var contentTextView: UITextView = {
        // MARK: TODO - placeholder 기능 만들기
        var textView = UITextView()
        textView.isScrollEnabled = false
        textView.font = .systemFont(ofSize: 16)
        textView.text = "내용을 입력해 주세요."
        return textView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        initNavigationBar()
        initUI()
    }
    
    func initNavigationBar(){
        self.navigationItem.title = "글쓰기"
        self.navigationItem.setRightBarButton(UIBarButtonItem(image: UIImage(systemName: "arrow.up"), style: .done, target: self, action: #selector(showCategoryList)), animated: true)
        self.navigationItem.rightBarButtonItem?.tintColor = .black
        // MARK: TODO - 하단 그림자
    }
    
    func initUI(){
        self.view.addSubview(scrollView)
        self.scrollView.addSubview(titleObjcetLabel)
        self.scrollView.addSubview(titleObjectButton)
        self.scrollView.addSubview(contentTextView)
        
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.trailing.leading.bottom.equalToSuperview()
        }
        
        titleObjcetLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(LEADINGTRAIINGOFFSET)
            make.trailing.equalToSuperview().offset(-LEADINGTRAIINGOFFSET)
            make.top.equalToSuperview()
            make.height.equalTo(60)
        }
        titleObjectButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(LEADINGTRAIINGOFFSET)
            make.trailing.equalToSuperview().offset(-LEADINGTRAIINGOFFSET)
            make.top.equalToSuperview()
            make.height.equalTo(60)
        }
        
        contentTextView.snp.makeConstraints { make in
            make.top.equalTo(titleObjcetLabel.snp.bottom)
            make.leading.equalToSuperview().offset(LEADINGTRAIINGOFFSET)
            make.trailing.equalToSuperview().offset(-LEADINGTRAIINGOFFSET)
            make.bottom.equalToSuperview()
            make.width.equalTo(scrollView.snp.width).offset(-LEADINGTRAIINGOFFSET * 2)
        }
    }
    
    @objc func showCategoryList(){
        
    }
}
