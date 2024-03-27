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
    var chatRoomModel: Observable<ChatRoomModel>
    var chatMembers = BehaviorRelay<[TestChatMemberModel]>(value: [])
    
    init(chatRoomModel: Observable<ChatRoomModel>) {
        self.chatRoomModel = chatRoomModel
        getChatRoomId()
            .flatMap{ roomId in
                return FirebaseFirestoreManager.shared.addListenerChatMembers(chatRoomId: roomId)
            }.bind(to: chatMembers)
            .disposed(by: self.disposeBag)
    }
    
    func getMembers() -> [TestChatMemberModel]{
        return chatMembers.value
    }
    
    func getMembersCount() -> Observable<Int>{
        return chatRoomModel.map{$0.memberCount}
    }
    
    func getMember(index: Int) -> TestChatMemberModel{
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
