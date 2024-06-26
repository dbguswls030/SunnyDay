//
//  CreateChatViewController.swift
//  Gardener
//
//  Created by 유현진 on 2/6/24.
//

import UIKit
import RxSwift
import SnapKit
import RxCocoa
import PhotosUI
import FirebaseAuth
class CreateChatViewController: UIViewController {

    var disposeBag = DisposeBag()
    
    private lazy var topView: UIView = {
        var view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        var label = UILabel()
        label.text = "채팅방 만들기"
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
    
    private lazy var createButton: UIButton = {
        var button = UIButton()
        button.setTitle("완료", for: .normal)
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
    
    private lazy var createChatView: CreateChatView = {
        return CreateChatView()
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        hideKeyboardWhenTouchUpBackground()
        initUI()
        backButtonAction()
        thumnailButtonAddTarget()
        toggleCreateButton()
        touchUpCreateButton()
    }
    

    private func initUI(){
        self.view.backgroundColor = .systemBackground
        self.view.addSubview(topView)
        self.view.addSubview(scrollView)
        self.topView.addSubview(titleLabel)
        self.topView.addSubview(backButton)
        self.topView.addSubview(createButton)
        self.scrollView.addSubview(createChatView)
        
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
        
        createButton.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.right.equalToSuperview().offset(-5)
            make.width.height.equalTo(45)
        }
        
        createChatView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview().offset(1)
        }
    }

    @objc private func backButtonAction(){
        self.dismiss(animated: true)
    }
    
    private func thumnailButtonAddTarget(){
        self.createChatView.thumnailImage.rx
            .tap
            .bind{
                self.touchUpThumnailButton()
            }.disposed(by: disposeBag)
        
    }
    
    private func toggleCreateButton(){
        self.createChatView.titleTextField.rx
            .text
            .orEmpty
            .bind{ text in
                if text.trimmingCharacters(in: .whitespaces).count == 0 {
                    self.createButton.isEnabled = false
                }else{
                    self.createButton.isEnabled = true
                }
            }.disposed(by: disposeBag)
    }
    
    private func touchUpCreateButton(){
        self.createButton.rx
            .tap
            .bind{
                self.showActivityIndicator(alpha: 0.2)
                self.dismissKeyboard()
                self.createChatRoomAPI()
            }.disposed(by: disposeBag)
    }
    
    func createChatRoomAPI(){
        guard let thumnailImage = self.createChatView.thumnailImage.imageView!.image else {
            return
        }
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        
        let getUser = FirebaseFirestoreManager.shared.getUserInfoWithRx(uid: uid)
        getUser.flatMap { userModel -> Observable<ChatRoomModel> in
            let title = self.createChatView.titleTextField.text!.trimmingCharacters(in: .whitespaces)
            let subTitle = self.createChatView.subTitleTextView.text!.trimmingCharacters(in: .whitespaces)
            let model = ChatRoomModel(title: title, subTitle: subTitle)
            return FirebaseFirestoreManager.shared.createChatRoomWithRx(model: model)
        }.flatMap{ chatRoomModel -> Observable<(String, ChatRoomModel)> in
            return FirebaseStorageManager.shared.uploadChatThumbnailImage(chatRoomId: chatRoomModel.roomId, image: thumnailImage).map{ url in (url, chatRoomModel)}
        }.flatMap{ url, chatRoomModel in
            return FirebaseFirestoreManager.shared.updateChatRoomThumbnail(chatRoomId: chatRoomModel.roomId, thumbailURL: url).map{ chatRoomModel }
        }.flatMap{ chatRoomModel in
            return Observable.zip(FirebaseFirestoreManager.shared.userEnteredChatRoom(uid: uid, chatRoomId: chatRoomModel.roomId), FirebaseFirestoreManager.shared.addChatRoomMember(chatRoomId: chatRoomModel.roomId, member: ChatMemberModel(level: 0, uid: uid)))
        }.bind{ _ in
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
            self.createChatView.thumnailImage.setImage(UIImage(named: "ralo"), for: .normal)
        }
        let actionCancel = UIAlertAction(title: "취소", style: .cancel)
        
        actionSheetController.addAction(showAlbum)
        actionSheetController.addAction(removeProfile)
        actionSheetController.addAction(actionCancel)
        
        self.present(actionSheetController, animated: true)
    }
}
extension CreateChatViewController: PHPickerViewControllerDelegate{
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        
        if let itemProvider = results.first?.itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self){
            let previousImage = self.createChatView.thumnailImage.imageView?.image
            self.showActivityIndicator(alpha: 0)
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                DispatchQueue.main.async {
                    guard let self = self, let image = image as? UIImage, self.createChatView.thumnailImage != previousImage else { return }
                    self.createChatView.thumnailImage.setImage(image, for: .normal)
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
