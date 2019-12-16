//
//  State.swift
//  ElectoralUniversity
//
//  Created by Evan Richard on 12/10/19.
//  Copyright © 2019 EvanRichard. All rights reserved.
//

import Foundation
import Firebase

struct State {

    var name: String
    var identifier: String
    var displayState: Bool = true

    var dictionary: [String: Any] {
        return [
          "name": name,
          "identifier": identifier,
          "displayState": displayState
        ]
    }

}

extension State {
    init?(dictionary: [String : Any]) {
        guard let name = dictionary["name"] as? String,
            let identifier = dictionary["identifier"] as? String
            else { return nil }
         
        self.init(name: name,  identifier: identifier)
    }
}
