//
//  CreateBoardViewController.swift
//  Gardener
//
//  Created by 유현진 on 2023/05/28.
//

import UIKit
import SnapKit
import PhotosUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore
import FirebaseStorage

// TODO: 업로드 시 indicator 

class CreateBoardViewController: UIViewController {
    
    weak var delegate: SendDelegateWhenPop?
    
    private final let LEADINGTRAIINGOFFSET = 15

    private var selectedImage: [UIImage] = []
    
    private lazy var topBreakLine: BreakLine = {
       return BreakLine()
    }()
    
    private lazy var scrollView: UIScrollView = {
        return UIScrollView()
    }()
    
    private lazy var categoryLabel: UILabel = {
        var label = UILabel()
        label.text = "카테고리를 선택해 주세요."
        label.font = .systemFont(ofSize: 17)
        return label
    }()
    
    private lazy var categoryButton: UIButton = {
        var button = UIButton()
        button.setImage(UIImage(systemName: "chevron.forward"), for: .normal)
        button.tintColor = .black
        button.contentHorizontalAlignment = .trailing
        button.addTarget(self, action: #selector(showCategoryList), for: .touchUpInside)
        return button
    }()
    
    private lazy var categoryTitleBreakLine: BreakLine = {
        return BreakLine()
    }()
    
    private lazy var titleTextView: UITextField = {
        var textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        textField.placeholder = "제목을 입력해 주세요.(최대 20자)"
        return textField
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
    
    private lazy var contentLimitLabel: UILabel = {
        let label = UILabel()
        label.text = "(0/300)"
        label.font = UIFont.systemFont(ofSize: 10)
        return label
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
        initObserver()
        hideKeyboard()
    }
    
    private func initNavigationBar(){
        self.navigationItem.title = "글쓰기"
        self.navigationItem.setRightBarButton(UIBarButtonItem(image: UIImage(systemName: "arrow.up"), style: .done, target: self, action: #selector(uploadBoard)), animated: true)
        self.navigationItem.rightBarButtonItem?.tintColor = .black
    }
    
    private func initUI(){
        self.view.backgroundColor = .white
        
        self.view.addSubview(topBreakLine)
        self.view.addSubview(scrollView)
        self.scrollView.addSubview(categoryLabel)
        self.scrollView.addSubview(categoryButton)
        self.scrollView.addSubview(titleTextView)
        self.scrollView.addSubview(categoryTitleBreakLine)
        self.scrollView.addSubview(contentTextView)
        self.scrollView.addSubview(contentLimitLabel)
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
        
        categoryLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(LEADINGTRAIINGOFFSET+5)
            make.trailing.equalToSuperview().offset(-LEADINGTRAIINGOFFSET)
            make.top.equalToSuperview()
            make.height.equalTo(60)
        }
        
        categoryButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(LEADINGTRAIINGOFFSET+5)
            make.trailing.equalToSuperview().offset(-LEADINGTRAIINGOFFSET)
            make.top.equalToSuperview()
            make.height.equalTo(60)
        }
        
        categoryTitleBreakLine.snp.makeConstraints { make in
            make.top.equalTo(categoryLabel.snp.bottom)
            make.leading.equalToSuperview().offset(LEADINGTRAIINGOFFSET)
            make.trailing.equalToSuperview().offset(-LEADINGTRAIINGOFFSET)
            make.height.equalTo(1)
        }
        
        titleTextView.snp.makeConstraints { make in
            make.top.equalTo(categoryTitleBreakLine.snp.bottom).offset(15)
            make.leading.equalToSuperview().offset(LEADINGTRAIINGOFFSET+5)
            make.trailing.equalToSuperview().offset(-LEADINGTRAIINGOFFSET)
        }
        titleTextView.delegate = self
        
        contentTextView.snp.makeConstraints { make in
            make.top.equalTo(titleTextView.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(LEADINGTRAIINGOFFSET)
            make.trailing.equalToSuperview().offset(-LEADINGTRAIINGOFFSET)
            make.bottom.equalToSuperview()
            make.width.equalTo(scrollView.snp.width).offset(-LEADINGTRAIINGOFFSET * 2)
        }
        contentTextView.delegate = self
        
        contentLimitLabel.snp.makeConstraints { make in
            make.bottom.equalTo(contentTextView.snp.bottom).offset(-2)
            make.right.equalTo(contentTextView.snp.right).offset(-2)
        }
        
        photoCollectionView.register(ShowPhotoPickerCollectionViewCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "addImage")
        photoCollectionView.register(SelectedPhotoCollectionViewCell.self, forCellWithReuseIdentifier: "selectedImage")

        photoCollectionView.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.bottom)
            make.height.equalTo(80)
            make.trailing.equalToSuperview().offset(-LEADINGTRAIINGOFFSET)
            make.leading.equalToSuperview().offset(LEADINGTRAIINGOFFSET)
            make.bottom.equalTo(self.view.keyboardLayoutGuide.snp.top)
        }
    }
    
    private func initObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(titleTextFieldDidChange), name: UITextField.textDidChangeNotification, object: titleTextView)
        NotificationCenter.default.addObserver(self, selector: #selector(contentTextViewDidChange), name: UITextView.textDidChangeNotification, object: contentTextView)
    }
    
    @objc func titleTextFieldDidChange(_ notification: Notification){
        if let textfield = notification.object as? UITextField{
            if let text = textfield.text{
                if text.count >= 20{
                    let index = text.index(text.startIndex, offsetBy: 20)
                    let newString = text[text.startIndex..<index]
                    titleTextView.text = String(newString)
                }
            }
        }
    }
    
    @objc func contentTextViewDidChange(_ notification: Notification){
        if let textView = notification.object as? UITextView{
            if let text = textView.text{
                if text.count >= 300{
                    let index = text.index(text.startIndex, offsetBy: 300)
                    let newString = text[text.startIndex..<index]
                    contentTextView.text = String(newString)
                }
                contentLimitLabel.text = "(\(contentTextView.text!.count)/300"
            }
        }
    }
    
    @objc private func uploadBoard(){
        guard let category = categoryLabel.text, category != "카테고리를 선택해 주세요." else{
            print("카테고리를 선택해 주세요.")
//            Toast().showToast(view: self.view, message: "카테고리를 선택해 주세요.")
            return
        }
        
        guard let contents = contentTextView.text, contents.count > 1, contents != "내용을 입력해 주세요." else{
//            Toast().showToast(view: self.view, message: "내용을 최소 두 글자 이상 입력해주세요.")
            print("내용을 최소 두 글자 이상 입력해주세요.")
            return
        }
        
        guard let title = titleTextView.text, title.count > 1 else{
//            Toast().showToast(view: self.view, message: "제목을 최소 두 글자 이상 입력해주세요.")
            print("제목을 최소 두글자 이상 입력해 주세요")
            return
        }
        
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        showActivityIndicator(alpha: 0.0)
        if let uid = Auth.auth().currentUser?.uid{
            FirebaseFirestoreManager.shared.getUserInfo(uid: uid) { [weak self] userModel in
                guard let self = self else { return }
                let boardId = UUID().uuidString + String(Date().timeIntervalSince1970)
                FirebaseStorageManager.shared.uploadBoardImages(images: self.selectedImage, boardId: boardId, uid: uid) { [weak self] contentImageURLs in
                    guard let self = self else { return }
                    FirebaseFirestoreManager.shared.uploadBoard(model: BoardModel(boardId: boardId, category: category, title: title, contents: contents, uid: uid, nickName: userModel.nickName, profileImageURL: userModel.profileImageURL, contentImageURLs: contentImageURLs)) { [weak self] in
                        guard let self = self else { return }
                        self.delegate?.popCreatBoard()
                        self.hideActivityIndicator(alpha: 0.0)
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
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
        dismissKeyboard()
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = .images
        configuration.selectionLimit = 5
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        
        self.present(picker, animated: true)
    }
}

extension CreateBoardViewController: SendCategoryDelegate{
    func changeCategory(category: String) {
        self.categoryLabel.text = category
    }
}
extension CreateBoardViewController: DeleteImageDelegate{
    @objc func deleteImage(sender: UIButton) {
        guard let cell = sender.superview as? UICollectionViewCell, let indexPath = photoCollectionView.indexPath(for: cell) else{ return }
        DispatchQueue.main.async {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
        self.selectedImage.remove(at: indexPath.item)
        self.photoCollectionView.deleteItems(at: [indexPath])
        self.photoCollectionView.performBatchUpdates {
            DispatchQueue.main.async {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            }
        }
    }
}

extension CreateBoardViewController: PHPickerViewControllerDelegate{
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)

        if !results.isEmpty{
            selectedImage.removeAll()
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()
            for result in results {
                DispatchQueue.main.async {
                    self.navigationItem.rightBarButtonItem?.isEnabled = false
                }
                let itemProvider = result.itemProvider
                if itemProvider.canLoadObject(ofClass: UIImage.self){
                    itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
                        if let image = image as? UIImage{
                            self?.selectedImage.append(image)
                            if self?.selectedImage.count == results.count{
                                dispatchGroup.leave()
                            }
                        }
                    }
                }
            }
            dispatchGroup.notify(queue: .global(), work: DispatchWorkItem{
                DispatchQueue.main.async {
                    self.photoCollectionView.reloadData()
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                }
                
            })
        }
    }
}

extension CreateBoardViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedImage.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader, let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "addImage", for: indexPath) as? ShowPhotoPickerCollectionViewCell else {
            return UICollectionReusableView()
        }
        header.pickerButton.addTarget(self, action: #selector(showMyAlbum), for: .touchUpInside)
        return header
     }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "selectedImage", for: indexPath) as? SelectedPhotoCollectionViewCell else{
            return UICollectionViewCell()
        }
        cell.updateImage(image: selectedImage[indexPath.item])
        cell.deleteButton.addTarget(self, action: #selector(deleteImage), for: .touchUpInside)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = collectionView.frame.width / 5
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width: CGFloat = collectionView.frame.width / 5
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 3, bottom: 0, right: 3)
    }
}
extension CreateBoardViewController: UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let char = string.cString(using: String.Encoding.utf8) {
            let isBackSpace = strcmp(char, "\\b")
            if isBackSpace == -92 {
                return true
            }
        }
        if textField == titleTextView {
            if titleTextView.text!.count > 20{
                return false
            }
        }
        return true
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
