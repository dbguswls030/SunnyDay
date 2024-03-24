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
    
    var chatRoomModel: Observable<ChatRoomModel>
    
    init(chatRoomModel: Observable<ChatRoomModel>) {
        self.chatRoomModel = chatRoomModel
    }
    
    func getMembers() -> Observable<[ChatMemberModel]>{
        return chatRoomModel.map{$0.members}
    }
    
    func getMembersCount() -> Observable<Int>{
        return chatRoomModel.map{$0.members.count}
    }
    
    func getMember(index: Int) -> Observable<ChatMemberModel>{
        return self.chatRoomModel.map{
            $0.members[index]
        }
    }
    
    func isAmMaster(uid: String) -> Observable<Bool>{
        return chatRoomModel.map {
            return $0
        }.compactMap { model in
            return model.members.filter{
                $0.uid == uid
            }.first
        }.map { model in
            model.level == 0 ? true : false
        }
    }
    
    func isAlone() -> Observable<Bool>{
        return chatRoomModel.map { model in
            model.members.count == 1 ? true : false
        }
    }
    
    func getChatRoomId() -> Observable<String>{
        return chatRoomModel.map{ model in
            model.roomId
        }
    }
    
}
