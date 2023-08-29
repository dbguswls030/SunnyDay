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
    
    private final let LEADINGTRAIINGOFFSET = 15

    private var selectedImage: [UIImage] = []
    
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
        self.navigationItem.setRightBarButton(UIBarButtonItem(image: UIImage(systemName: "arrow.up"), style: .done, target: self, action: #selector(uploadBoard)), animated: true)
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
               
    @objc private func uploadBoard(){
        guard let category = titleObjcetLabel.text, category != "카테고리를 선택해 주세요." else{
//            Toast().showToast(view: self.view, message: "카테고리를 선택해 주세요.")
            return
        }
        
        guard let contents = contentTextView.text, contents.count > 1, contents != "내용을 입력해 주세요." else{
//            Toast().showToast(view: self.view, message: "내용을 최소 두 글자 이상 입력해주세요.")
            return
        }
        
        let db = Firestore.firestore()
        
        if let uid = Auth.auth().currentUser?.uid{
            if !selectedImage.isEmpty{
                let boardId = UUID().uuidString + String(Date().timeIntervalSince1970)
                FirebaseStorageManager.uploadBoardImages(images: selectedImage, boardId: boardId, uid: uid) { urls in
                    db.collection("community").addDocument(data: ["category" : category,
                                                                  "contents" :contents,
                                                                  "uid" : uid,
                                                                  "date" : Timestamp(date: Date()),
                                                                  "imageUrl" : urls]) { error in
                        if error != nil {
                            FirebaseStorageManager.deleteBoard(boardId: boardId, uid: uid)
//                            Toast().showToast(view: self.view, message: "게시글 업로드를 실패했습니다.")
                        }else{
//                            Toast().showToast(view: self.view, message: "게시글 업로드를 성공하였습니다.")
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }else{
                db.collection("community").addDocument(data: ["category" : category,
                                                              "contents" :contents,
                                                              "uid" : uid,
                                                              "date" : Timestamp(date: Date()),
                                                              "imageUrl" : [String]()]) { error in
                    if error != nil {
//                        Toast().showToast(view: self.view, message: "게시글 업로드를 실패했습니다.")
                    }else{
//                        Toast().showToast(view: self.view, message: "게시글 업로드를 성공하였습니다.")
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
