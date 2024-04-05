//
//  ProfileViewController.swift
//  Gardener
//
//  Created by 유현진 on 3/17/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class ProfileViewController: UIViewController {
    
    let myUid: String
    let profileUid: String
    let chatRoomId: String
    
    var disposeBag = DisposeBag()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.clipsToBounds = true
        scrollView.layer.cornerRadius = 15
        scrollView.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMinYCorner, .layerMaxXMinYCorner)
        scrollView.backgroundColor = .white
        return scrollView
    }()
    
    private lazy var profileHalfView: ProfileHalfView = {
        return ProfileHalfView()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        profileHalfView.setData(profileUid: self.profileUid, myUid: self.myUid, chatRoomId: self.chatRoomId)
        addExpulsionButtonAction()
        addTapGestureDismiss()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.scrollView.snp.updateConstraints { make in
                make.height.equalTo(210)
            }
            self?.view.layoutIfNeeded()
        }
    }
    
    init(profileUid: String, chatRoomId: String, myUid: String){
        self.profileUid = profileUid
        self.chatRoomId = chatRoomId
        self.myUid = myUid
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initUI(){
        self.view.backgroundColor = .black.withAlphaComponent(0.4)
        
        self.view.addSubview(scrollView)
        self.scrollView.addSubview(profileHalfView)
        
        scrollView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(0)
        }
        
        profileHalfView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
    }
    
    private func addExpulsionButtonAction(){
        profileHalfView.expulsionButton.isUserInteractionEnabled = true
        profileHalfView.expulsionButton.rx
            .tap
            .bind{ [weak self] _ in
                guard let self = self else { return }
                self.showPopUp(title:"정말 추방하시겠습니까?", confirmButtonTitle: "추방하기") { [weak self] in
                    guard let self = self else { return }
                    FirebaseFirestoreManager.shared.WhoAreYouAtChatRoom(chatRoomId: self.chatRoomId, uid: self.profileUid)
                        .bind{ [weak self] level in
                            guard let self = self else { return }
                            if level == 2{
                                Observable.zip(FirebaseFirestoreManager.shared.userExitedChatRoom(uid: self.profileUid, chatRoomId: self.chatRoomId),
                                               FirebaseFirestoreManager.shared.exitChatRoom(roomId: self.chatRoomId, uid: self.profileUid)
                                               ,FirebaseFirestoreManager.shared.updateExpelledUserMessage(chatRoomId: self.chatRoomId, uid: self.profileUid))
                                .observe(on: MainScheduler.instance)
                                .bind{ [weak self] _ in
                                    guard let self = self else { return }
                                    self.dismiss(animated: false)
                                    UIView.animate(withDuration: 0.3) { [weak self] in
                                        self?.scrollView.snp.updateConstraints { make in
                                            make.bottom.equalTo(210)
                                        }
                                        self?.view.backgroundColor = .clear
                                        self?.view.layoutIfNeeded()
                                    } completion: { [weak self] _ in
                                        self?.dismiss(animated: false)
                                    }
                                }.disposed(by: self.disposeBag)
                            }else{
                                self.dismiss(animated: false)
                                self.showPopUp(title: "관리자와 매니저는 추방할 수 없어요!") {
                                    
                                }
                                
                            }
                        }.disposed(by: self.disposeBag)
                    
                }
            }.disposed(by: self.disposeBag)
    }
    
    private func addTapGestureDismiss(){
        let tapGesture = UITapGestureRecognizer()
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        self.view.isUserInteractionEnabled = true
        
        tapGesture.rx.event
            .bind{ _ in
                UIView.animate(withDuration: 0.3) { [weak self] in
                    self?.scrollView.snp.updateConstraints { make in
                        make.bottom.equalTo(210)
                    }
                    self?.view.backgroundColor = .clear
                    self?.view.layoutIfNeeded()
                } completion: { [weak self] _ in
                    self?.dismiss(animated: false)
                }
            }.disposed(by: self.disposeBag)
    }
    
    
}

extension ProfileViewController: UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard touch.view?.isDescendant(of: self.scrollView) == false else { return false }
        return true
      }
}
