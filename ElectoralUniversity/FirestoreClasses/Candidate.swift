//
//  Candidate.swift
//  ElectoralUniversity
//
//  Created by Evan Richard on 10/19/19.
//  Copyright © 2019 EvanRichard. All rights reserved.
//

import Foundation

struct Candidate {

  var name: String
  var id: String
  var screenName: String
  var profileImg: String
  var bannerImg: String
  var responses: Dictionary<String, Int>

  var dictionary: [String: Any] {
    return [
      "name": name,
      "id": id,
      "screenName": screenName,
      "profileImg": profileImg,
      "bannerImg": bannerImg,
      "responses": responses
    ]
  }

}

extension Candidate{
    init?(dictionary: [String : Any]) {
        guard let name = dictionary["name"] as? String,
            let id = dictionary["id"] as? String,
            let screenName = dictionary["screen_name"] as? String,
            let profileImg = dictionary["profile_image_url"] as? String,
            let bannerImg = dictionary["profile_banner_url"] as? String,
            let responses = dictionary["responses"] as? Dictionary<String, Int>
            else { return nil }
         
        self.init(name: name,  id: id, screenName: screenName, profileImg: profileImg, bannerImg: bannerImg, responses: responses)
    }
}
