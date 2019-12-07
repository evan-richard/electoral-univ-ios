//
//  Issue.swift
//  ElectoralUniversity
//
//  Created by Evan Richard on 10/19/19.
//  Copyright © 2019 EvanRichard. All rights reserved.
//

import Foundation

struct Stance {
    var id: Int
    var text: String
    
    var dictionary: [String: Any] {
        return [
            "id": id,
            "text": text
        ]
    }
}

extension Stance {
    init?(dictionary: [String : Any]) {
        guard let id = dictionary["id"] as? Int,
            let text = dictionary["text"] as? String
            else { return nil }
         
        self.init(id: id,  text: text)
    }
}

struct Issue {

  var id: String
  var policy: String
  var topic: String
  var question: String
  var stances: Array<Stance>

  var dictionary: [String: Any] {
    return [
      "id": id,
      "policy": policy,
      "topic": topic,
      "question": question,
      "stances": stances
    ]
  }

}

extension Issue{
    init?(dictionary: [String : Any]) {
        guard let id = dictionary["id"] as? String,
            let policy = dictionary["policy"] as? String,
            let topic = dictionary["topic"] as? String,
            let question = dictionary["question"] as? String,
            let stances:[Stance] = [] as? [Stance]
            else { return nil }
         
        self.init(id: id,  policy: policy, topic: topic, question: question, stances: stances)
        self.buildStancesArray(stancesArr: (dictionary["stances"] as? Array<[String: Any]>))
    }
    
    mutating func buildStancesArray(stancesArr: Array<[String: Any]>?){
        var resultArr:Array<Stance> = []
        for item in stancesArr ?? [] {
            if let stance: Stance = Stance(dictionary: item) {
                resultArr.append(stance)
            }
        }
        self.stances = resultArr
    }
}
