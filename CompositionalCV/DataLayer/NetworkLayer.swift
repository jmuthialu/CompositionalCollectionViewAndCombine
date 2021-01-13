//
//  NetworkLayer.swift
//  5-JayCompositional
//
//  Created by Jay Muthialu on 1/4/20.
//  Copyright © 2020 Jay Muthialu. All rights reserved.
//

import Foundation
import Combine

struct Constants {
    static let scheme = "https"
    static let baseUrl = "api.unsplash.com"
    static let path = "/search/photos"
    static let clientId = "12ed97d4dfa3d6c2cb6b05e407bec679de632f8392b37ec23df0b3809979e337"
    static let featuredTerm = "dogs" // used in MainVC
    static let sharedTerm = "cats" // used in MainVC
    static let generalTerm = "beach" // used in MainVC
    static let detailViewSearchTerm = "office" // used in DetailVC
}

class NetworkLayer {
    
    static var cancellables = Set<AnyCancellable>()
    
    static func constructURL(searchTerm: String) -> URL? {
        var components = URLComponents()
        components.scheme = Constants.scheme
        components.host = Constants.baseUrl
        components.path = Constants.path
        components.queryItems = [
            URLQueryItem(name: "page", value: "1"),
            URLQueryItem(name: "query", value: searchTerm),
            URLQueryItem(name: "client_id", value: Constants.clientId)
        ]
        return components.url
    }
    
    static func loadData<T: Decodable>(url: URL,
                                       completion: @escaping (T?, Error?) -> Void ) {
        
        let pub = URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data) // maps only data and ignores response
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
        
        pub
            .sink(receiveCompletion: { rcvcompletion in
                    switch rcvcompletion {
                    case .finished:
                        break
                    case .failure(let error):
                        print("Network Layer: \(error.localizedDescription)")
                        completion(nil, error)
                    }
                }, receiveValue: { value in
                    completion(value, nil)
                }).store(in: &cancellables)

    }
}

