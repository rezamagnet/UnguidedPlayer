//
// Track.swift
//  
// Created by Reza Khonsari on 12/7/24.
// Copyright © 2024 Reza Khonsari. All rights reserved.
//
// Linkedin: https://www.linkedin.com/in/rezakhonsari-ios/
// Github: https://github.com/rezamagnet
//

import Foundation

public struct Track {
    var title: String?
    var subtitle: String?
    var streamURL: URL?
    var animation: Animation
    var favorited: Bool?
    var unguidedSecond: TimeInterval?
    
    public struct Animation {
        let backgroundAnimationURL: URL?
        let backgroundVolume: Int?
        
        public init(backgroundAnimationURL: URL?, backgroundVolume: Int?) {
            self.backgroundAnimationURL = backgroundAnimationURL
            self.backgroundVolume = backgroundVolume
        }
    }
    
    public init(
        title: String?,
        subtitle: String?,
        streamURL: URL?,
        animation: Animation,
        favorited: Bool?,
        unguidedSecond: TimeInterval?
    ) {
        self.title = title
        self.subtitle = subtitle
        self.streamURL = streamURL
        self.animation = animation
        self.favorited = favorited
        self.unguidedSecond = unguidedSecond
    }
}
