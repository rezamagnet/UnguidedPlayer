//
// ContentView.swift
// UnguidedPlayer
//
// Created by Reza Khonsari on 12/7/24.
// Copyright © 2024 Reza Khonsari. All rights reserved.
//
// Linkedin: https://www.linkedin.com/in/rezakhonsari-ios/
// Github: https://github.com/rezamagnet
//

import SwiftUI

struct ContentView: View {
    
    @State var isLiked = false
    
    var body: some View {
        RKUnguidedPlayerView(
            viewModel: RKUnguidedPlayerViewModel(
                track: Track(
                    title: PlayerConfig.title,
                    subtitle: PlayerConfig.instructor,
                    streamURL: PlayerConfig.streamURL,
                    animation: Track.Animation(
                        backgroundAnimationURL: PlayerConfig.animationVideo,
                        backgroundVolume: PlayerConfig.animationVolume
                    ),
                    favorited: PlayerConfig.isLiked,
                    unguidedSecond: PlayerConfig.unguidedSecond
                ),
                likeAction: {
                    withAnimation {
                        isLiked.toggle()                        
                    }
                    return isLiked
                }
            )
        )
    }
}

#Preview {
    ContentView()
}
