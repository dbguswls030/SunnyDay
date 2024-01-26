//
//  ChatViewModel.swift
//  Gardener
//
//  Created by 유현진 on 1/26/24.
//

import Foundation
import RxSwift

class ChatViewModel{
    
    var chatList: [ChatModel]
    
    init(){
        chatList = [ChatModel(title: "1"), ChatModel(title: "2")]
    }
    
    func getChatList() -> Observable<[ChatModel]>{
        return Observable.just(chatList)
    }
}
