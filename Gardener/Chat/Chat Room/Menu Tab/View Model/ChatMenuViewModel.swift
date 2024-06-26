//
//  ChatMenuViewModel.swift
//  Gardener
//
//  Created by 유현진 on 3/1/24.
//

import Foundation
import RxSwift
import RxCocoa

class ChatMenuViewModel{
    var disposeBag = DisposeBag()
    var chatRoomModel = BehaviorSubject<ChatRoomModel>(value: .init(title: "", subTitle: ""))

    var chatMembers = BehaviorRelay<[ChatMemberModel]>(value: [])
    
    init(chatRoomId: String) {
        FirebaseFirestoreManager.shared.addListenerChatRoom(chatRoomId: chatRoomId)
            .bind(to: self.chatRoomModel)
            .disposed(by: self.disposeBag)
        
        FirebaseFirestoreManager.shared.addListenerChatMemberCount(chatRoomId: chatRoomId)
            .flatMap {
                FirebaseFirestoreManager.shared.getChatMembers(chatRoomId: chatRoomId)
            }
        //            .skip(1) // MARK: logical Error 처음에 리턴 갯수가 이상함
            .bind(to: chatMembers)
            .disposed(by: self.disposeBag)
    }
    
    func getMembersCount() -> Observable<Int>{
        return chatRoomModel.map{$0.memberCount}
    }
    
    func getMember(index: Int) -> ChatMemberModel{
        return chatMembers.value[index]
    }
    
    func isAmMaster(uid: String) -> Observable<Bool>{
        return getChatRoomId()
            .flatMap { roomId in
                return FirebaseFirestoreManager.shared.getChatMember(chatRoomId: roomId, uid: uid)
            }.map{
                $0.level == 0
            }
    }
    
    
    func isAmNotCommon(uid: String) -> Observable<Bool>{
        return getChatRoomId()
            .flatMap { roomId in
                return FirebaseFirestoreManager.shared.getChatMember(chatRoomId: roomId, uid: uid)
            }.map{
                $0.level != 2
            }
    }
    
    func isAlone() -> Observable<Bool>{
        return chatRoomModel.map { model in
            model.memberCount == 1 ? true : false
        }
    }
    
    func getChatRoomId() -> Observable<String>{
        return chatRoomModel.map{ model in
            model.roomId
        }
    }
    
}
