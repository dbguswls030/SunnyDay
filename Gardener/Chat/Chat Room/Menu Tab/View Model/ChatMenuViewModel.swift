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
}
