//
//  FeedModel.swift
//  5-JayCompositional
//
//  Created by Jay Muthialu on 1/3/20.
//  Copyright © 2020 Jay Muthialu. All rights reserved.
//

import Foundation

class FeedModel: Decodable {
    
    var pictures: [PictureModel] = []
    
    enum CodingKeys: CodingKey {
        case results
    }
    
    required init(from decoder: Decoder) {
        do {
            let rootContainer = try decoder.container(keyedBy: CodingKeys.self)
            var resultsContainer = try rootContainer.nestedUnkeyedContainer(forKey: CodingKeys.results)
            while !resultsContainer.isAtEnd {
                let picture = try resultsContainer.decode(PictureModel.self)
                pictures.append(picture)
            }
            print("Count of pictures: \(pictures.count)")
        } catch let e {
            print("Error occurred decoding \(type(of: self)): \(e)")
        }
        
    }
}

