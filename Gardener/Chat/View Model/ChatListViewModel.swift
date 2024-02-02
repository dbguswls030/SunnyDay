//
//  ChatViewModel.swift
//  Gardener
//
//  Created by 유현진 on 1/26/24.
//

import Foundation
import RxSwift

class ChatListViewModel{
    
    var chatRoomList: [ChatRoomModel]
    
    init(){
        chatRoomList = [ChatRoomModel(title: "1"), ChatRoomModel(title: "2")]
    }
    
    func getChatRoomList() -> Observable<[ChatRoomModel]>{
        return Observable.just(chatRoomList)
    }
}
