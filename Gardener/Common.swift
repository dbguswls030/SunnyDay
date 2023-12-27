//
//  Common.swift
//  Gardener
//
//  Created by 유현진 on 2023/06/05.
//

import Foundation
import UIKit
import SnapKit

extension UIControl{
    func addAction(for controlEvent: UIControl.Event = .touchUpInside, _ closure: @escaping () -> ()){
        @objc class EscapeAction: NSObject {
            let closure: () -> ()
            
            init(_ closure: @escaping () -> ()) {
                self.closure = closure
            }
            
            @objc func invoke() {
                closure()
            }
        }
        let sleeve = EscapeAction(closure)
        addTarget(sleeve, action: #selector(EscapeAction.invoke), for: controlEvent)
        objc_setAssociatedObject(self, "\(UUID())", sleeve, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }
}


enum BoardCategory: String, CaseIterable{
    case free = "자유"
    case question = "질문/답변"
}

extension UIViewController {
    func hideKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
            action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

class BreakLine: UIView{
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .lightGray
        self.alpha = 0.2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class PopUpViewController: UIViewController{
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "정말 댓글을 삭제하시겠습니까?"
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    lazy var confirmButton: UIButton = {
        let button = UIButton()
        button.setTitle("확인", for: .normal)
        button.backgroundColor = .green.withAlphaComponent(0.3)
        button.layer.cornerRadius = 8
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("취소", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .lightGray.withAlphaComponent(0.2)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(cancelButtonAction), for: .touchUpInside)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        return button
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 15
        view.sizeToFit()
        return view
    }()
    
    private func initUI(){
        self.view.backgroundColor = .black.withAlphaComponent(0.3)
        self.view.addSubview(contentView)
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(stackView)
        
        contentView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(55)
            make.right.equalToSuperview().offset(-55)
        }
        
        [cancelButton, confirmButton].map{ button in
            self.stackView.addArrangedSubview(button)
            button.snp.makeConstraints { make in
                make.height.equalTo(button.snp.width).multipliedBy(0.3)
            }
            
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalToSuperview().offset(30)
        }
        
        stackView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    func setTitleLabel(title: String){
        self.titleLabel.text = title
    }

    
    func setConfirmButtonText(text: String){
        self.confirmButton.setTitle(text, for: .normal)
    }
    
    @objc private func cancelButtonAction(){
        self.dismiss(animated: false)
    }
    
    override func viewDidLoad() {
        initUI()
    }
    
}

extension UIViewController{
    func showPopUp(title: String? = nil, confirmButtonTitle: String? = nil, completion: @escaping () -> ()){
        let vc = PopUpViewController()
        vc.modalPresentationStyle = .overFullScreen
        if let title = title{
            vc.setTitleLabel(title: title)
        }
        
        if let confirmButtonTitle = confirmButtonTitle{
            vc.setConfirmButtonText(text: confirmButtonTitle)
            vc.confirmButton.addAction {
                completion()
            }
        }

        self.present(vc, animated: false)
        
    }
}

extension UIViewController{
    func showActivityIndicator(alpha: CGFloat){
        let overlayView = UIView(frame: view.bounds)
        overlayView.backgroundColor = UIColor(white: 0, alpha: alpha)
        
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.center = overlayView.center
        overlayView.addSubview(activityIndicator)
        
        self.view.addSubview(overlayView)
        activityIndicator.startAnimating()
    }
    
    func hideActivityIndicator(alpha: CGFloat){
        self.view.subviews.filter { $0.backgroundColor == UIColor(white: 0, alpha: alpha) }.forEach {
            $0.removeFromSuperview()
        }
    }
}

extension Date{
    func convertDateToTime() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.timeZone = TimeZone(abbreviation: "KST")
        guard let convertDate = dateFormatter.date(from: dateFormatter.string(from: self)) else {
            return "알 수 없음"
        }
        
        let intervalTime = Int(floor(Date().timeIntervalSince(convertDate) / 60))
        if intervalTime < 1 {
            return "방금 전"
        }else if intervalTime < 60 {
            return "\(intervalTime)분 전"
        }else if intervalTime < 60 * 24{
            return "\(intervalTime/60)시간 전"
        }else if intervalTime < 60 * 24 * 365{
            return "\(intervalTime/60/24)일 전"
        }else{
            return "\(intervalTime/60/24/365)년 전"
        }
    }
}
