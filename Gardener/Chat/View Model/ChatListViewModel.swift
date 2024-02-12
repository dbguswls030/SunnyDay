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
        chatRoomList = [ChatRoomModel(title: "1", subTitle: "주식", members: []), ChatRoomModel(title: "2", subTitle: "머", members: [])]
    }
    
    func getChatRoomList() -> Observable<[ChatRoomModel]>{
        return Observable.just(chatRoomList)
    }
}
