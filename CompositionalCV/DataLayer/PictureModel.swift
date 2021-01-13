//
//  PictureModel.swift
//  5-JayCompositional
//
//  Created by Jay Muthialu on 1/4/20.
//  Copyright © 2020 Jay Muthialu. All rights reserved.
//

import Foundation

class PictureModel: Decodable, Hashable {

    var id: String = ""
    var description: String?
    var fullUrl: String?

    enum PictureModelCodingKeys: String, CodingKey {
        case id = "id"
        case description = "description"
        case urls = "urls"
        case full = "full"
    }
    
    init() {} // for deep copy
    
    required init(from decoder: Decoder) {
        do {
            let container = try decoder.container(keyedBy: PictureModelCodingKeys.self)
            self.id = try container.decode(String.self, forKey: PictureModelCodingKeys.id)
            
            // descrition field in JSON is null sometimes and this give decoder error. To avoid the errors use
            // decodeIfPresent with nill coalescing operator
            self.description = try container.decodeIfPresent(String.self, forKey: PictureModelCodingKeys.description) ?? ""
            
            let urlsDict = try container.nestedContainer(keyedBy: PictureModelCodingKeys.self , forKey: PictureModel.PictureModelCodingKeys.urls)
            self.fullUrl = try urlsDict.decode(String.self, forKey: PictureModelCodingKeys.full)
        } catch let e {
            print("Error at \(type(of: self)): \(e)")
        }
    }
    
    func hash(into hasher: inout Hasher) {
      hasher.combine(identifier)
    }
    
    static func == (lhs: PictureModel, rhs: PictureModel) -> Bool {
        lhs.identifier == rhs.identifier
    }
    
    // To duplicate pictures
    func deepCopy() -> PictureModel {
        let picture = PictureModel()
        picture.id = self.id
        picture.description = self.description
        picture.fullUrl = self.fullUrl
        return picture
    }
    
    private let identifier = UUID()
}
