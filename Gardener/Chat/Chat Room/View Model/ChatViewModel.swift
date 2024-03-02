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
    
    let chatRoomId: String
    var chatRoomModel: Observable<ChatRoomModel>
    var messages = BehaviorRelay<[ChatMessageModel]>(value: [])
    var disposeBag = DisposeBag()

    
    init(chatRoomId: String){
        self.chatRoomId = chatRoomId
        self.chatRoomModel = FirebaseFirestoreManager.shared.addListenerChatRoom(chatRoomId: chatRoomId).asObservable()
        
    }
    
    func getFirstChatMessages() -> Observable<Void>{
        return Observable.create { emitter in
            FirebaseFirestoreManager.shared.getFirstChatMessages(chatRoomId: self.chatRoomId)
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
            FirebaseFirestoreManager.shared.addListenerChatMessage(chatRoomId: self.chatRoomId)
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
    
    
    func getChatRoomTitle() -> Observable<String>{
        return chatRoomModel.map{ return $0.title }
    }
}
