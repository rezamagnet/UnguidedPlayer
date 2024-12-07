//
// BackgroundPlayerManager.swift
//
// Created by Reza Khonsari on 12/7/24.
// Copyright © 2024 Reza Khonsari. All rights reserved.
//
// Linkedin: https://www.linkedin.com/in/rezakhonsari-ios/
// Github: https://github.com/rezamagnet
//

import Foundation
import AVFoundation

class BackgroundPlayerManager {
    private var track: Track
    
    private var looperPlayer: AVPlayerLooper?
    private var noiseLooperPlayer: AVPlayerLooper?
    private var backgroundPlayer: AVPlayer?
    private(set) var noisePlayer: AVPlayer?

    init(track: Track, onSetup: @escaping (AVPlayer?, AVPlayer?) -> Void) {
        self.track = track
        setupBackgroundVideo()
        onSetup(backgroundPlayer, noisePlayer)
    }
    
    func seekToZero() {
        noisePlayer?.seek(to: .zero)
        backgroundPlayer?.seek(to: .zero)
    }
    
    func play() {
        backgroundPlayer?.play()
        noisePlayer?.play()
    }
    
    func pause() {
        backgroundPlayer?.pause()
        noisePlayer?.pause()
    }
    
    func destroy() {
        looperPlayer = nil
        noiseLooperPlayer = nil
        backgroundPlayer = nil
        noisePlayer = nil
    }
    
    var backgroundVideo: (url: URL, volume: Float)? {
        if let animationURL = track.animation.backgroundAnimationURL {
            let volume = Float(track.animation.backgroundVolume ?? 0) / 100
            return (animationURL, volume)
        } else {
            return nil
        }
    }
    
    func mute() {
        noisePlayer?.isMuted = true
    }
    
    func unmute() {
        noisePlayer?.isMuted = false
    }
    
    private func setupBackgroundVideo() {
        if let backgroundVideo {
            let asset = AVURLAsset(url: backgroundVideo.url)
            let playerItem = AVPlayerItem(asset: asset)
            let queuePlayer = AVQueuePlayer(playerItem: playerItem)
            looperPlayer = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
            backgroundPlayer = queuePlayer
            backgroundPlayer?.isMuted = true
            backgroundPlayer?.volume = 0
            
            let noiseFile = Bundle.main.url(forResource: "white noise -30 copy", withExtension: "mp3")!
            let noiseAsset = AVURLAsset(url: noiseFile)
            let noisePlayerItem = AVPlayerItem(asset: noiseAsset)
            let noiseQueuePlayer = AVQueuePlayer(playerItem: noisePlayerItem)
            noiseLooperPlayer = AVPlayerLooper(player: noiseQueuePlayer, templateItem: noisePlayerItem)
            
            noisePlayer = noiseQueuePlayer
            noisePlayer?.volume = backgroundVideo.volume
        }
    }
}
