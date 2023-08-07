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
import PhotosUI

// TODO: 프로필 사진 선택 시 앨범보기, 이미지 삭제 바
// TODO: 프로필 사진 -> 앨범 선택 시 프로필 사진 업데이트


class SignUpViewController: UIViewController {

    private lazy var signView: SignUpView = {
        return SignUpView()
    }()
    
    var uid = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initUI()
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
        signView.profileImage.addTarget(self, action: #selector(showMyAlbum(_ :)), for: .touchUpInside)
    }
    
    @objc private func setProfile(_ sender: Any){
        let db = Firestore.firestore()
        db.collection("user").document(self.uid).setData(["nickName" : String(describing: signView.nickNameTextField.text),
                                                          "profileImage" : ""])
    }
    
    @objc private func showMyAlbum(_ sender: Any){
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
