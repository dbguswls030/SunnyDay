//
//  SearchChatRoomViewModel.swift
//  Gardener
//
//  Created by 유현진 on 2/20/24.
//

import Foundation
import RxSwift
import RxCocoa

class SearchChatRoomViewModel{
    var searchChatRoomList = BehaviorSubject<[ChatRoomModel]>(value: [])
    
    func getChatRoomList(keyword: String) -> Observable<[ChatRoomModel]>{
        return Observable.create{ emitter in
            
            return Disposables.create()
        }
    }
}
