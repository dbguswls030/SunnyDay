//
//  ChatViewModel.swift
//  Gardener
//
//  Created by 유현진 on 1/26/24.
//

import Foundation
import RxSwift
import FirebaseFirestore
import FirebaseAuth
import RxCocoa

class ChatListViewModel{
    var disposeBag = DisposeBag()
    var chatRooms = BehaviorRelay<[ChatRoomModel]>(value: [])
    
    init(){
        FirebaseFirestoreManager.shared.addListenerParticipatedChatRoomId(uid: Auth.auth().currentUser!.uid)
            .flatMap { participatedChatRoomIdList in
                return FirebaseFirestoreManager.shared.getChatRoomWithChatRoomId(chatRoomIdList: participatedChatRoomIdList)
            }.bind(to: chatRooms)
            .disposed(by: disposeBag)
    }
    
    func isAmMaster(index: Int, uid: String) -> Observable<Bool>{
        return FirebaseFirestoreManager.shared.getChatMember(chatRoomId: getChatRoom(index: index).roomId, uid: uid)
            .map{
                $0.level == 0
            }
    }
    
    func getChatRoom(index: Int) -> ChatRoomModel{
        return chatRooms.value[index]
    }
   
    func isAlone(index: Int) -> Bool{
        return chatRooms.value[index].memberCount == 1 ? true : false
    }
}
