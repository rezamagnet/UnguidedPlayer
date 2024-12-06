//
// VideoPlayerView.swift
//
// Created by Reza Khonsari on 12/7/24.
// Copyright © 2024 Reza Khonsari. All rights reserved.
//
// Linkedin: https://www.linkedin.com/in/rezakhonsari-ios/
// Github: https://github.com/rezamagnet
//

import SwiftUI
import AVKit

struct VideoPlayerView: UIViewControllerRepresentable {
    
    @Binding var player: AVPlayer?
    @Binding var isAudioPlayed: Bool
    let onPlaying: () -> Void
    
    func makeUIViewController(context: Context) -> VideoPlayerViewController {
        let vc = VideoPlayerViewController()
        vc.player = player
        vc.updatesNowPlayingInfoCenter = false
        vc.allowsPictureInPicturePlayback = false
        vc.onPlaying = onPlaying
        return vc
    }
    
    func updateUIViewController(_ uiViewController: VideoPlayerViewController, context: Context) {
        uiViewController
            .isAudioPlayed = isAudioPlayed
    }
    
    typealias UIViewControllerType = VideoPlayerViewController
    
}

class VideoPlayerViewController: AVPlayerViewController {
    
    private var backgroundPlayerItemBufferKeepUpObserver: NSKeyValueObservation?
    private var backgroundPlayerItemBufferFullObserver: NSKeyValueObservation?
    
    var isAudioPlayed: Bool?
    var onPlaying: () -> Void = { }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundPlayerItemBufferKeepUpObserver = player?.currentItem?.observe(\AVPlayerItem.isPlaybackLikelyToKeepUp, options: [.new]) { [weak self] _,_  in
            self?.onPlaying()
            
            if self?.isAudioPlayed == true {
                self?.player?.playImmediately(atRate: 1)
            }
        }
        
        backgroundPlayerItemBufferFullObserver = player?.currentItem?.observe(\AVPlayerItem.isPlaybackBufferFull, options: [.new]) { [weak self] _,_  in
            self?.onPlaying()
        }
    }
}
