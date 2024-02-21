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
    let chatRooms = BehaviorRelay<[ChatRoomModel]>(value: [])
    
    init(){
        FirebaseFirestoreManager.shared.addListenerParticipatedChatRoomId(uid: Auth.auth().currentUser!.uid)
            .flatMap { participatedChatRoomIdList in
                return FirebaseFirestoreManager.shared.getChatRoomWithChatRoomId(chatRoomIdList: participatedChatRoomIdList)
            }.bind(to: chatRooms)
            .disposed(by: disposeBag)
    }
}
