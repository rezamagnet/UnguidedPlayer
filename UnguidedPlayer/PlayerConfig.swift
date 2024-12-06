//
// PlayerConfig.swift
// UnguidedPlayer
//
// Created by Reza Khonsari on 12/7/24.
// Copyright © 2024 Reza Khonsari. All rights reserved.
//
// Linkedin: https://www.linkedin.com/in/rezakhonsari-ios/
// Github: https://github.com/rezamagnet
//


import Foundation

struct PlayerConfig {
    static let title = "Deep Breath Morning Cycle"
    static let instructor = "William Pratt"
    static let streamURL: URL = Bundle.main.url(forResource: "Improving Creativity-Mychal-15m-895s-v2", withExtension: "mp3")!
    static let animationVideo: URL = Bundle.main.url(forResource: "Class category mobile", withExtension: "mp4")!
    static let animationVolume: Int = 50
    static let unguidedSecond: Double = 100
    static let isLiked: Bool = false
}
