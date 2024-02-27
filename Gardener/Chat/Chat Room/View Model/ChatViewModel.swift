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
//        FirebaseFirestoreManager.shared.testGetFirstChatMessages(chatRoom: self.chatRoomModel)
//            .bind(to: messages)
//            .disposed(by: disposeBag)
//        
//        FirebaseFirestoreManager.shared.addListenerChatMessage(chatRoom: self.chatRoomModel)
//            .scan(self.messages.value, accumulator: { messages, newMessages in
//                return messages + newMessages
//            })
//            .bind(to: messages)
//            .disposed(by: self.disposeBag)
    }
    
    func getFirstChatMessages() -> Observable<Void>{
        return Observable.create { emitter in
            FirebaseFirestoreManager.shared.testGetFirstChatMessages(chatRoom: self.chatRoomModel)
                .bind{ messages in
                    self.messages.accept(messages)
                    emitter.onNext(())
                    emitter.onCompleted()
                }
                .disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    func addListenerChatMessages() -> Observable<([ChatMessageModel], [ChatMessageModel])>{
        return Observable.create{ emitter in
            FirebaseFirestoreManager.shared.addListenerChatMessage(chatRoom: self.chatRoomModel)
                .map{ newMessages in
                    return (self.messages.value, newMessages)
                }
                .bind{ messages, newMessages in
                    emitter.onNext((messages, newMessages))
                }
                .disposed(by: self.disposeBag)
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
