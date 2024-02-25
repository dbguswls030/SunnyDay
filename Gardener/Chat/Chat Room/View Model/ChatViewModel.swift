//
//  ChatViewModel.swift
//  Gardener
//
//  Created by 유현진 on 2/1/24.
//

import Foundation
import RxSwift
import RxCocoa

class ChatViewModel{
    
    var chatRoomModel: ChatRoomModel
    var messages = BehaviorRelay<[ChatMessageModel]>(value: [])
    var disposeBag = DisposeBag()

    
    init(chatRoomModel: ChatRoomModel){
        self.chatRoomModel = chatRoomModel
    }
    
    func testGetFirstChatMessages() -> Observable<[ChatMessageModel]>{
        return Observable.create{ emitter in
            FirebaseFirestoreManager.shared.testGetFirstChatMessages(chatRoom: self.chatRoomModel)
                .bind{ messages in
                    self.messages.accept(messages)
                    emitter.onNext(messages)
                }.disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    func testGetChatMessagesListener() -> Observable<[ChatMessageModel]>{
        return Observable.create{ emitter in
            FirebaseFirestoreManager.shared.addListenerChatMessage(chatRoom: self.chatRoomModel)
                .scan(self.messages.value, accumulator: { messages, newMessages in
                    return messages + newMessages
                })
                .bind{ messages in
                    emitter.onNext(messages)
                }.disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    func getChatMessageListener() -> Observable<([ChatMessageModel], Int)>{
        return Observable.create{ emitter in
            FirebaseFirestoreManager.shared.addListenerChatMessage(chatRoom: self.chatRoomModel)
                .scan(self.messages.value, accumulator: { messages, newMessages in
                    return messages + newMessages
                })
                .flatMap{ updateMessages -> Observable<([ChatMessageModel], Int)> in
                    let previousMessageCount = self.messages.value.count
                    self.messages.accept(updateMessages)
                    return .just((updateMessages, updateMessages.count - previousMessageCount))
                }
                .bind{ messages, newMessageCount in
                    emitter.onNext((messages, newMessageCount))
                }.disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    func getChatModel(at index: Int) -> ChatMessageModel? {
        guard index >= 0, index < messages.value.count else {
            return nil
        }
        return messages.value[index]
    }
    
    
    func getChatRoomTitle() -> String{
        return chatRoomModel.title
    }
}
