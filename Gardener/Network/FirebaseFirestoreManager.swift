//
//  FirebaseStoreManager.swift
//  Gardener
//
//  Created by 유현진 on 2023/08/12.
//

import Foundation
import FirebaseFirestore


class FirebaseFirestoreManager{
    static func getCommunityBoards(query: Query?, completion: @escaping ([BoardModel], Query) -> Void){
        let db = Firestore.firestore()
        let request: Query
        
        if let query = query{
            request = query
        }else{
            request = db.collection("community").order(by: "date", descending: true).limit(to: 10)
        }

        request.addSnapshotListener { snapshot, error in
            if let error = error{
                print("getCommunity erorr = \(error.localizedDescription)")
                return
            }
            guard let snapshot = snapshot else{
                return
            }
            guard let lastShapshot = snapshot.documents.last else{
                return
            }
            var models = [BoardModel]()
            print("snapshot.foreach")
            snapshot.documents.forEach { document in
                
                if let data = document.data() as? [String: Any]{
                    if let category = data["category"] as? String,
                       let contents = data["contents"] as? String,
                       let date = data["date"] as? Timestamp,
                       let images = data["imageUrl"] as? [String],
                       let uid = data["uid"] as? String {
                        models.append(BoardModel(category: category,
                                                 contents: contents,
                                                 date: date.dateValue(),
                                                 images: images,
                                                 uid: uid))
                    }
                }
                //                do{
//                    let jsonData = try JSONSerialization.data(withJSONObject: document.data(), options: [])
//                    let data = try JSONDecoder().decode(BoardModel.self, from: jsonData)
//                    models.append(data)
//                }catch let error{
//                    print("json decoder error : \(error.localizedDescription)")
//                }
            } 
            completion(models, db.collection("community").order(by: "date", descending: true).limit(to: 10).start(afterDocument: lastShapshot))
        }
    }
}
