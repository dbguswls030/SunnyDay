//
//  SignUpViewController.swift
//  Gardener
//
//  Created by 유현진 on 2023/07/17.
//

import UIKit
import SnapKit
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import PhotosUI


// TODO: 사진 고르고 프로필 사진 업데이트 되는 동안 시작 버튼 잠금 -> button.ImageView 업데이트 부분과 button.image 변수 분리하기
// TODO: 시작 버튼 클릭 후 로딩 표시

class SignUpViewController: UIViewController {

    private lazy var signView: SignUpView = {
        return SignUpView()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initUI()
        initObserver()
        hideKeyboard()
    }
    
    private func initUI(){
        self.view.addSubview(signView)
        
        signView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        signView.nickNameTextField.delegate = self
        signView.nickNameTextField.addTarget(self, action: #selector(minimumNickNameLength(_ :)), for: .editingChanged)
        signView.submitButton.addTarget(self, action: #selector(setProfile(_ :)), for: .touchUpInside)
        signView.profileImage.addTarget(self, action: #selector(touchUpProfileImage(_ :)), for: .touchUpInside)
    }
    
    private func initObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(nickNameTextFieldDidChange), name: UITextField.textDidChangeNotification, object: signView.nickNameTextField)
    }
    
    @objc func nickNameTextFieldDidChange(_ notification: Notification){
        if let textfield = notification.object as? UITextField{
            if let text = textfield.text{
                if text.count >= 8{
                    let index = text.index(text.startIndex, offsetBy: 8)
                    let newString = text[text.startIndex..<index]
                    signView.nickNameTextField.text = String(newString)
                }
            }
        }
    }
    
    @objc private func touchUpProfileImage(_ sender: Any){
        let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
        let showAlbum = UIAlertAction(title: "앨범에서 선택", style: .default) { action in
            self.showMyAlbum()
        }
        let removeProfile = UIAlertAction(title: "기본 이미지로 변경", style: .destructive) { action in
            self.signView.profileImage.setImage(UIImage(named: "defaultProfileImage"), for: .normal)
        }
        let actionCancel = UIAlertAction(title: "취소", style: .cancel)
        
        actionSheetController.addAction(showAlbum)
        actionSheetController.addAction(removeProfile)
        actionSheetController.addAction(actionCancel)
        
        self.present(actionSheetController, animated: true)
    }
    
    @objc private func setProfile(_ sender: Any){
        let db = Firestore.firestore()
        guard let uploadProfileImage = self.signView.profileImage.imageView?.image else { return }
        print("isExist uploadProfileImage")
        if let user = Auth.auth().currentUser{
            FirebaseStorageManager.uploadProfileImage(image: uploadProfileImage, pathRoot: user.uid) { [weak self] url in
                guard let self = self else {return}
                if let url = url {
                    FirebaseFirestoreManager.shared.setUserInfo(uid: user.uid, model: UserModel(nickName: self.signView.nickNameTextField.text!, profileImageURL: url.absoluteString)) { result in
                        switch result{
                        case .success(let bool):
                            let vc = MainTabBarController()
                            vc.modalPresentationStyle = .fullScreen
                            self.present(vc, animated: true)
                        case .failure(let error):
                            print("d")
                        }
                    }
//                    print("download url = \(url)")
//                    db.collection("user").document(user.uid).setData(["nickName" : String(describing: self.signView.nickNameTextField.text!),
//                                                                      "profileImage" : url.absoluteString])
                    
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
extension SignUpViewController: PHPickerViewControllerDelegate{
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        
        if let itemProvider = results.first?.itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self){
            let previousImage = self.signView.profileImage.imageView?.image
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                DispatchQueue.main.async {
                    guard let self = self, let image = image as? UIImage, self.signView.profileImage != previousImage else { return }
                    self.signView.profileImage.setImage(image, for: .normal)
                }
            }
        }
    }
}

extension SignUpViewController: UITextFieldDelegate{
    @objc func minimumNickNameLength(_ sender: Any?){
        if let text = signView.nickNameTextField.text{
            if text.count < 2{
                signView.submitButton.isEnabled = false
                signView.submitButton.backgroundColor = .lightGray
            }else{
                signView.submitButton.isEnabled = true
                signView.submitButton.backgroundColor = .green
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let char = string.cString(using: String.Encoding.utf8) {
            let isBackSpace = strcmp(char, "\\b")
            if isBackSpace == -92 {
                return true
            }
        }
        guard signView.nickNameTextField.text!.count < 8 else{
            return false
        }
        return true
    }
}
