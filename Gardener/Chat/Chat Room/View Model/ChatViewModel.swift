//
//  ChatViewModel.swift
//  Gardener
//
//  Created by 유현진 on 2/1/24.
//

import Foundation
import RxSwift

class ChatViewModel{
    var chatList = BehaviorSubject<[ChatModel]>(value: [])
    
    
    init(){
        
    }
    
    func getChatModel(at index: Int) -> ChatModel? {
        guard let chatListValue = try? chatList.value() else {
            return nil
        }
        guard index >= 0, index < chatListValue.count else {
            return nil
        }
        return chatListValue[index]
    }
}
