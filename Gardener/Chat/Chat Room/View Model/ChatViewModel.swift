//
//  ChatViewModel.swift
//  Gardener
//
//  Created by 유현진 on 2/1/24.
//

import Foundation
import RxSwift

class ChatViewModel{
    
    var chatRoomModel: ChatRoomModel
    var messages = BehaviorSubject<[ChatMessageModel]>(value: [])
    var disposeBag = DisposeBag()

    
    init(chatRoomModel: ChatRoomModel){
        self.chatRoomModel = chatRoomModel
        FirebaseFirestoreManager.shared.addListenerChatMessage(chatRoom: chatRoomModel)
            .bind(to: messages)
            .disposed(by: disposeBag)
    }
    
    
    
    func getChatModel(at index: Int) -> ChatMessageModel? {
        guard let chatListValue = try? messages.value() else {
            return nil
        }
        guard index >= 0, index < chatListValue.count else {
            return nil
        }
        return chatListValue[index]
    }
    
    
    func getChatRoomTitle() -> String{
        return chatRoomModel.title
    }
}
