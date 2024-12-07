//
//  RKUnguidedPlayerViewModel.swift
//
// Created by Reza Khonsari on 12/7/24.
// Copyright © 2024 Reza Khonsari. All rights reserved.
//
// Linkedin: https://www.linkedin.com/in/rezakhonsari-ios/
// Github: https://github.com/rezamagnet
//

import Foundation
import AVFoundation
import Combine

public final class RKUnguidedPlayerViewModel: ObservableObject {
    
    var cancellables: Set<AnyCancellable> = []
    @Published var isPlaying = false
    @Published var isFinished = false
    @Published var isUnguidedPart: Bool = false
    @Published var trackFavorited: Bool = false
    /// Display time that will be bound to the scrub slider.
    @Published var displayTime: TimeInterval = 0
    /// Amount time player is available
    @Published var itemDuration: TimeInterval = 0
    
    @Published var backgroundPlayer: AVPlayer?
    @Published var noisePlayer: AVPlayer?
    
    var displayTimeFormattedText: String {
        durationFormatter.string(from: displayTime)!
    }
    
    var displayTitle: String {
        if player?.isUnguidedPart == true {
            return "Unguided"
        } else {
            return track.title ?? ""
        }
    }
    
    var subtitleTile: String {
        if player?.isUnguidedPart == true {
            return "End of class"
        } else {
            return track.subtitle ?? ""
        }
    }
    
    var displayItemDurationFormattedText: String {
        let unguidedSecond = track.unguidedSecond ?? 0
        let value = abs(itemDuration - displayTime - unguidedSecond + 1)
        if player?.isUnguidedPart == true {
            return "+" + durationFormatter.string(from: value)!
        } else {
            return "-" + durationFormatter.string(from: value - 1)!
        }
    }
    
    private var likeAction: () -> Bool
    
    private(set) var track: Track
    private var player: RKPlayer?
    var backgroundPlayerManager: BackgroundPlayerManager?
    
    let durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    
    public init(
        track: Track,
        likeAction: @escaping () -> Bool
    ) {
        self.player = RKPlayer(track: track)
        self.track = track
        self.likeAction = likeAction
        self.backgroundPlayerManager = BackgroundPlayerManager(track: track) { [weak self] backgroundVideo, noiseVideo in
            self?.backgroundPlayer = backgroundVideo
            self?.noisePlayer = noiseVideo
        }
        
        self.player?.displayTimeSubject
            .sink(receiveValue: { [weak self] time in
                self?.displayTime = time
            })
            .store(in: &cancellables)
        
        self.player?.itemDurationSubject
            .sink(receiveValue: { [weak self] time in
                self?.itemDuration = time
            })
            .store(in: &cancellables)
    }
    
    func updateScrub(_ scrub: PlayerScrubState) {
        player?.scrubState = scrub
        isUnguidedPart = player?.isUnguidedPart ?? false
    }
    
    func destroyAll() {
        player?.destroy()
        backgroundPlayerManager?.destroy()
    }
    
    func trackFavoritedAction() {
        trackFavorited = likeAction()
    }
    
    func mute() {
        player?.mute()
        backgroundPlayerManager?.mute()
    }
    
    func unmute() {
        player?.unmute()
        backgroundPlayerManager?.unmute()
    }
    
    func appearAction() {
        
        // MARK: - sound player handle
        player?.onStart = { [weak self] in
            self?.player?.play()
            self?.isPlaying = true
        }
        
        player?.onFinish = { [weak self] in
            self?.backgroundPlayerManager?.pause()
            self?.backgroundPlayerManager?.destroy()
            self?.player?.pause()
            self?.isFinished = true
        }
        
        player?.onStart = { [weak self] in
            self?.backgroundPlayerManager?.play()
            self?.isPlaying = true
        }
        
        player?.onPlay = { [weak self] in
            self?.backgroundPlayerManager?.play()
            self?.isPlaying = true
        }
        
        player?.onPause = { [weak self] in
            self?.backgroundPlayerManager?.pause()
            self?.isPlaying = false
        }
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.isUnguidedPart = self.player?.isUnguidedPart ?? false
        }
        
        player?.play()
    }
}

extension RKUnguidedPlayerViewModel {
    private var playerIsPlaying: Bool { player?.isPlaying ?? false }
    var isPlayerDurationMoreThanZero: Bool { player?.itemDurationSubject.value ?? 0 > 0 }
    
    func playAction() {
        if isPlaying {
            backgroundPlayerManager?.pause()
            player?.pause()
            isPlaying = false
        } else {
            backgroundPlayerManager?.play()
            player?.play()
            isPlaying = true
        }
    }
    
    func rewindAction() {
        player?.backward()
    }
}
