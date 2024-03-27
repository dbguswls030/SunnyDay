//
//  ChatViewModel.swift
//  Gardener
//
//  Created by 유현진 on 2/1/24.
//

import Foundation
import RxSwift
import RxCocoa
import FirebaseFirestore

class ChatViewModel{
    
    let chatRoomId: String
    var chatRoomModel: Observable<ChatRoomModel>
    var messages = BehaviorRelay<[ChatMessageModel]>(value: [])
    var disposeBag = DisposeBag()
    
    var previousMessagesQuery: Query?
    
    init(chatRoomId: String){
        self.chatRoomId = chatRoomId
        self.chatRoomModel = FirebaseFirestoreManager.shared.addListenerChatRoom(chatRoomId: chatRoomId).asObservable()
        
    }
    
    func getFirstChatMessages() -> Observable<Void>{
        return Observable.create { emitter in
            FirebaseFirestoreManager.shared.getFirstChatMessages(chatRoomId: self.chatRoomId)
                .bind{ messages, query in
                    self.previousMessagesQuery = query
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
    
    func getPreviousMessages() -> Observable<Int>{
        return Observable.create{ emitter in
            guard let previousMessagesQuery = self.previousMessagesQuery else{
                emitter.onCompleted()
                return Disposables.create()
            }
            FirebaseFirestoreManager.shared.getPreviousMessages(query: previousMessagesQuery, chatRoomId: self.chatRoomId)
                .bind{ previousMessages, query in
                    self.previousMessagesQuery = query
                    self.messages.accept(previousMessages+self.messages.value)
                    emitter.onNext(previousMessages.count)
                    emitter.onCompleted()
                }.disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    
    func getChatMessageModel(at index: Int) -> ChatMessageModel? {
        guard index >= 0, index < messages.value.count else {
            return nil
        }
        return messages.value[index]
    }
    
    func getChatRoomTitle() -> Observable<String>{
        return chatRoomModel.map{ return $0.title }
    }
}
