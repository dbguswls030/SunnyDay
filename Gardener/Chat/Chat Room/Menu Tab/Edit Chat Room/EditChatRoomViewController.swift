//
//  EditChatRoomViewController.swift
//  Gardener
//
//  Created by 유현진 on 4/4/24.
//

import UIKit
import RxSwift
import SnapKit
import RxCocoa
import PhotosUI
import FirebaseAuth

class EditChatRoomViewController: UIViewController {
    
    var disposeBag = DisposeBag()
    var chatRoomModel: ChatRoomModel
    var isChangedThumbnailImage = false
    
    private lazy var topView: UIView = {
        var view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        var label = UILabel()
        label.text = "채팅방 수정하기"
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    private lazy var backButton: UIButton = {
        var button = UIButton()
        button.tintColor = .black
        button.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        return button
    }()
    
    private lazy var editButton: UIButton = {
        var button = UIButton()
        button.setTitle("수정", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.lightGray, for: .disabled)
        button.isEnabled = false
        return button
    }()
    
    private lazy var scrollView: UIScrollView = {
        var scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var editChatView: CreateChatView = {
        return CreateChatView()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTouchUpBackground()
        initUI()
        initSubTitleTextView()
        backButtonAction()
        thumnailButtonAddTarget()
        touchUpEditButton()
        setData()
        // Do any additional setup after loading the view.
    }
    
    init(chatRoomModel: ChatRoomModel){
        self.chatRoomModel = chatRoomModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func initUI(){
        self.view.backgroundColor = .systemBackground
        self.view.addSubview(topView)
        self.view.addSubview(scrollView)
        self.topView.addSubview(titleLabel)
        self.topView.addSubview(backButton)
        self.topView.addSubview(editButton)
        self.scrollView.addSubview(editChatView)
        
        topView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.height.equalTo(45)
        }
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(self.view.keyboardLayoutGuide.snp.top)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }
        
        backButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.width.height.equalTo(45)
        }
        
        editButton.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.right.equalToSuperview().offset(-5)
            make.width.height.equalTo(45)
        }
        
        editChatView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview().offset(1)
        }
    }
    
    @objc private func backButtonAction(){
        self.dismiss(animated: true)
    }
    
    private func thumnailButtonAddTarget(){
        self.editChatView.thumnailImage.rx
            .tap
            .bind{
                self.touchUpThumnailButton()
            }.disposed(by: disposeBag)
        
    }
    
    private func toggleEditButton(){
        let titleObservable = self.editChatView.titleTextField.rx
            .text
            .orEmpty
        
        let subTitleObservable = self.editChatView.subTitleTextView.rx
            .text
            .orEmpty
        
        Observable.zip(titleObservable, subTitleObservable)
            .bind{ title, subTitle in
                if title.trimmingCharacters(in: .whitespaces).count == 0 {
                    self.editButton.isEnabled = false
                }else{
                    self.editButton.isEnabled = true
                }
            }.disposed(by: disposeBag)
    }
    
    func setData(){
        self.editChatView.titleTextField.text = self.chatRoomModel.title
        self.editChatView.subTitleTextView.text = self.chatRoomModel.subTitle
        self.showActivityIndicator(alpha: 0.2)
        self.editChatView.initLimitLabel()
        URLSession.shared.dataTask(with: URL(string: self.chatRoomModel.thumbnailURL)!) { data, response, error in
            guard let data = data, error == nil else {
                return
            }
            DispatchQueue.main.async {
                self.editChatView.thumnailImage.setImage(UIImage(data: data), for: .normal)
                self.hideActivityIndicator(alpha: 0.2)
                self.toggleEditButton()
            }
        }.resume()
    }
    
    private func initSubTitleTextView(){
        if self.editChatView.subTitleTextView.text.isEmpty{
            
        }else{
            self.editChatView.subTitleTextView.textColor = .black
            self.editChatView.subTitleTextView.resolveHashTags()
        }
    }
    
    private func touchUpEditButton(){
        self.editButton.rx
            .tap
            .bind{
                self.showActivityIndicator(alpha: 0.2)
                self.dismissKeyboard()
                self.editChatRoomAPI()
            }.disposed(by: disposeBag)
    }
    
    func editChatRoomAPI(){
        guard let thumnailImage = self.editChatView.thumnailImage.imageView!.image else {
            return
        }
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        
        let getUser = FirebaseFirestoreManager.shared.getUserInfoWithRx(uid: uid)
        getUser.flatMap { userModel in
            let title = self.editChatView.titleTextField.text!.trimmingCharacters(in: .whitespaces)
            let subTitle = self.editChatView.subTitleTextView.text!.trimmingCharacters(in: .whitespaces)
            return FirebaseFirestoreManager.shared.updateChatRoom(chatRoomId: self.chatRoomModel.roomId, title: title, subTitle: subTitle)
        }.flatMap{
            if self.isChangedThumbnailImage{
                return FirebaseStorageManager.shared.uploadChatThumbnailImage(chatRoomId: self.chatRoomModel.roomId, image: thumnailImage).flatMap{
                    return FirebaseFirestoreManager.shared.updateChatRoomThumbnail(chatRoomId: self.chatRoomModel.roomId, thumbailURL: $0).flatMap{
                        return FirebaseStorageManager.shared.deleteChatThumbnailImage(chatRoomId: self.chatRoomModel.roomId, thumbnailURL: self.chatRoomModel.thumbnailURL)
                    }
                }
            }else{
                return Observable.just(())
            }
        }
//        .flatMap{ url in
//            return FirebaseFirestoreManager.shared.updateChatRoomThumbnail(chatRoomId: self.chatRoomModel.roomId, thumbailURL: url)
//        }.flatMap{
//            return FirebaseStorageManager.shared.deleteChatThumbnailImage(chatRoomId: self.chatRoomModel.roomId, thumbnailURL: self.chatRoomModel.thumbnailURL)
//        }
        .bind{ _ in
            self.hideActivityIndicator(alpha: 0.2)
            UIView.animate(withDuration: 0.2) {
                self.view.alpha = 0
            }completion: { _ in
                self.dismiss(animated: false)
            }
        }.disposed(by: disposeBag)
    }
    
    private func touchUpThumnailButton(){
        let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let showAlbum = UIAlertAction(title: "앨범에서 선택", style: .default) { action in
            self.showMyAlbum()
        }
        let removeProfile = UIAlertAction(title: "기본 이미지로 변경", style: .destructive) { action in
            self.editChatView.thumnailImage.setImage(UIImage(named: "ralo"), for: .normal)
        }
        let actionCancel = UIAlertAction(title: "취소", style: .cancel)
        
        actionSheetController.addAction(showAlbum)
        actionSheetController.addAction(removeProfile)
        actionSheetController.addAction(actionCancel)
        
        self.present(actionSheetController, animated: true)
    }
}
extension EditChatRoomViewController: PHPickerViewControllerDelegate{
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        
        if let itemProvider = results.first?.itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self){
            let previousImage = self.editChatView.thumnailImage.imageView?.image
            self.showActivityIndicator(alpha: 0)
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                DispatchQueue.main.async {
                    guard let self = self, let image = image as? UIImage, self.editChatView.thumnailImage != previousImage else { return }
                    self.editChatView.thumnailImage.setImage(image, for: .normal)
                    self.editButton.isEnabled = true
                    self.isChangedThumbnailImage = true
                    self.hideActivityIndicator(alpha: 0)
                }
            }
        }
    }
    
    private func showMyAlbum(){
        dismissKeyboard()
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = .images
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        
        self.present(picker, animated: true)
    }
}

