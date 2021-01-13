//
//  MainViewModel.swift
//  5-JayCompositional
//
//  Created by Jay Muthialu on 1/13/21.
//  Copyright © 2021 Jay Muthialu. All rights reserved.
//

import Foundation
import Combine

class MainViewModel {
    
    var featuredNotificationName = Notification.Name(Section.featured.rawValue)
    var sharedNotificationName = Notification.Name(Section.shared.rawValue)
    var generalNotificationName = Notification.Name(Section.general.rawValue)
    
    var featuredNotification: Notification?
    var sharedNotification: Notification?
    var generalNotification: Notification?
    
    var featuredPub: NotificationCenter.Publisher?
    var sharedPub: NotificationCenter.Publisher?
    var generalPub: NotificationCenter.Publisher?
    
    var featuredPictures = [PictureModel]()
    var sharedPictures = [PictureModel]()
    var generalPictures = [PictureModel]()
    
    var cancellables = Set<AnyCancellable>()
    
    init() {
        featuredNotification = Notification(name: featuredNotificationName)
        sharedNotification = Notification(name: sharedNotificationName)
        generalNotification = Notification(name: generalNotificationName)
        
        featuredPub = NotificationCenter.default.publisher(for: featuredNotificationName)
        sharedPub = NotificationCenter.default.publisher(for: sharedNotificationName)
        generalPub = NotificationCenter.default.publisher(for: generalNotificationName)
    }
    
    func loadData() {
        
        guard let featuredUrl = NetworkLayer.constructURL(searchTerm: Constants.featuredTerm),
              let sharedUrl = NetworkLayer.constructURL(searchTerm: Constants.sharedTerm),
              let generalUrl = NetworkLayer.constructURL(searchTerm: Constants.generalTerm) else { return }
        
        guard let featuredNotification = featuredNotification,
              let sharedNotification = sharedNotification,
              let generalNotification = generalNotification else { return }
        
        NetworkLayer.loadData(url: featuredUrl) {
            [weak self] (feed: FeedModel?, error: Error?) in
            
            guard let feed = feed, error == nil else {
                print("Error occured loading Data: \(String(describing: error))")
                return
            }
            
            let duplicates = feed.pictures.map { $0.deepCopy() }
            self?.featuredPictures = feed.pictures + duplicates
            print("posting featured...")
            NotificationCenter.default.post(featuredNotification)
        }

        NetworkLayer.loadData(url: sharedUrl) {
            [weak self] (feed: FeedModel?, error: Error?) in
            
            guard let feed = feed, error == nil else {
                print("Error occured loading Data: \(String(describing: error))")
                return
            }
            
            let duplicates = feed.pictures.map { $0.deepCopy() }
            self?.sharedPictures = feed.pictures + duplicates
            print("posting shared...")
            NotificationCenter.default.post(sharedNotification)
        }
        
        NetworkLayer.loadData(url: generalUrl) {
            [weak self] (feed: FeedModel?, error: Error?) in
            
            guard let feed = feed, error == nil else {
                print("Error occured loading Data: \(String(describing: error))")
                return
            }
            
            let duplicates = feed.pictures.map { $0.deepCopy() }
            self?.generalPictures = feed.pictures + duplicates
            print("posting general...")
            NotificationCenter.default.post(generalNotification)
        }
    }
}
