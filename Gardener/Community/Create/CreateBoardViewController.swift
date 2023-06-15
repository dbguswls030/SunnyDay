//
//  CreateBoardViewController.swift
//  Gardener
//
//  Created by 유현진 on 2023/05/28.
//

import UIKit
import SnapKit
import PhotosUI

// TODO: 앨범 보기
// TODO: 사진 다중 선택 시 완료 후 collectionView 업데이트
    // TODO: collectionViewCell 작성

// TODO: 내용 글자 제한 수

class CreateBoardViewController: UIViewController {
    
    private final let LEADINGTRAIINGOFFSET = 15
    
    var itemProviders: [NSItemProvider] = []
    var iterator: IndexingIterator<[NSItemProvider]>?
    
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
        textView.delegate = self
        return textView
    }()
    
    private lazy var photoCollectionView: UICollectionView = {
        var layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8
        var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationBar()
        initUI()
        hideKeyboard()
    }
    
    private func initNavigationBar(){
        self.navigationItem.title = "글쓰기"
//        self.navigationItem.setRightBarButton(UIBarButtonItem(image: UIImage(systemName: "arrow.up"), style: .done, target: self, action: #selector(), animated: true)
//        self.navigationItem.rightBarButtonItem?.tintColor = .black
    }
    
    private func initUI(){
        self.view.backgroundColor = .white
        
        self.view.addSubview(topBreakLine)
        self.view.addSubview(scrollView)
        self.scrollView.addSubview(titleObjcetLabel)
        self.scrollView.addSubview(titleObjectButton)
        self.scrollView.addSubview(titleContentBreakLine)
        self.scrollView.addSubview(contentTextView)
        self.view.addSubview(photoCollectionView)
        
        topBreakLine.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.trailing.leading.equalToSuperview()
            make.height.equalTo(1)
        }
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(topBreakLine.snp.bottom)
            make.trailing.leading.equalToSuperview()
            make.bottom.equalTo(photoCollectionView.snp.top)
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
        
        photoCollectionView.register(ShowPhotoPickerCollectionViewCell.self, forCellWithReuseIdentifier: "addImage")
        photoCollectionView.register(SelectedPhotoCollectionViewCell.self, forCellWithReuseIdentifier: "selectedImage")

        photoCollectionView.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.bottom)
            make.height.equalTo(80)
            make.trailing.equalToSuperview().offset(-LEADINGTRAIINGOFFSET)
            make.leading.equalToSuperview().offset(LEADINGTRAIINGOFFSET)
            make.bottom.equalTo(self.view.keyboardLayoutGuide.snp.top)
        }
    }
    
    @objc private func showCategoryList(){
        let vc = CategoryViewController()
        vc.sheetPresentationController?.detents = [.medium()]
        vc.sheetPresentationController?.preferredCornerRadius = 30
        vc.delegate = self
        self.present(vc, animated: true)
    }
    
    @objc private func showMyAlbum(){
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 5
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        
        self.present(picker, animated: true)
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

extension CreateBoardViewController: PHPickerViewControllerDelegate{
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        
        self.itemProviders = results.map(\.itemProvider)
        iterator = itemProviders.makeIterator()
    }
}

extension CreateBoardViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemProviders.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0{
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addImage", for: indexPath) as? ShowPhotoPickerCollectionViewCell else{
                return UICollectionViewCell()
            }
            cell.pickerButton.addTarget(self, action: #selector(showMyAlbum), for: .touchUpInside)
            return cell
        }else{
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0{
        }else{
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = collectionView.frame.width / 5
        return CGSize(width: width - 3, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 3, bottom: 0, right: 3)
    }
}
