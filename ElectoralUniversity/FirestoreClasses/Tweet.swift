//
//  Tweet.swift
//  ElectoralUniversity
//
//  Created by Evan Richard on 10/19/19.
//  Copyright © 2019 EvanRichard. All rights reserved.
//

import Foundation
import Firebase

struct Tweet {

    var text: String
    var authorId: String
    var timestamp: Date
    var retweet: Dictionary<String, String>?
    var media: Array<Dictionary<String, String>>?
    var urls: Array<Dictionary<String, String>>?

    var dictionary: [String: Any] {
        return [
          "text": text,
          "authorId": authorId,
          "timestamp": timestamp,
          "retweet": retweet ?? [:],
          "media": media ?? [],
          "urls": urls ?? []
        ]
    }

}

extension Tweet{
    init?(dictionary: [String : Any]) {
        guard let text = dictionary["tweet"] as? String,
            let authorId = dictionary["author_id"] as? String,
            let timestamp = (dictionary["timestamp"] as? Timestamp)?.dateValue(),
            let retweet = dictionary["retweet"] as? Dictionary<String, String>?,
            let media = dictionary["media"] as? Array<Dictionary<String, String>>,
            let urls = dictionary["urls"] as? Array<Dictionary<String, String>>
            else { return nil }
         
        self.init(text: text,  authorId: authorId, timestamp: timestamp, retweet: retweet, media: media, urls: urls)
    }
}
