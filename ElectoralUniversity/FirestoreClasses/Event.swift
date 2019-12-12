//
//  Event.swift
//  ElectoralUniversity
//
//  Created by Evan Richard on 12/8/19.
//  Copyright © 2019 EvanRichard. All rights reserved.
//
import Foundation
import Firebase

struct Event {

    var id: String
    var state: String
    var lastUpdate: Date
    var dateStr: String
    var party: String?
    var type: String

    var dictionary: [String: Any] {
        return [
          "id": id,
          "state": state,
          "lastUpdate": lastUpdate,
          "dateStr": dateStr,
          "party": party ?? "",
          "type": type
        ]
    }

}

extension Event {
    init?(dictionary: [String : Any]) {
        guard let id = dictionary["id"] as? String,
            let state = dictionary["state"] as? String,
            let lastUpdate = (dictionary["last_updated"] as? Timestamp)?.dateValue(),
            let dateStr = dictionary["date_str"] as? String,
            let party = dictionary["party"] as? String?,
            let type = dictionary["type"] as? String
            else { return nil }
         
        self.init(id: id,  state: state, lastUpdate: lastUpdate, dateStr: dateStr, party: party, type: type)
    }
}
