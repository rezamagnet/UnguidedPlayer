//
// RKPlayer.swift
//
// Created by Reza Khonsari on 12/7/24.
// Copyright © 2024 Reza Khonsari. All rights reserved.
//
// Linkedin: https://www.linkedin.com/in/rezakhonsari-ios/
// Github: https://github.com/rezamagnet
//

import AVFoundation
import Combine
import MediaPlayer

let timeScale = CMTimeScale(1000)
let time = CMTime(seconds: 0.5, preferredTimescale: timeScale)

enum PlayerScrubState {
    case reset
    case scrubStarted(TimeInterval)
    case scrubEnded(TimeInterval)
}

/// AVPlayer wrapper to publish the current time and
/// support a slider for scrubbing.
final class RKPlayer {
    
    private var track: Track
    
    /// Display time that will be bound to the scrub slider.
    var displayTimeSubject: CurrentValueSubject<TimeInterval, Never> = .init(0)
    
    
    /// The observed time, which may not be needed by the UI.
    var observedTime: TimeInterval = 0
    
    var itemDurationSubject: CurrentValueSubject<TimeInterval, Never> = .init(0)
    fileprivate var itemDurationKVOPublisher: AnyCancellable?
    
    /// Publish timeControlStatus
    var timeControlStatus: AVPlayer.TimeControlStatus = .paused
    fileprivate var timeControlStatusKVOPublisher: AnyCancellable?
    
    /// The AVPlayer
    fileprivate var avPlayer: AVPlayer?
    
    var isPlaying: Bool { avPlayer?.rate != 0 }
    
    var rate: Float { avPlayer?.rate ?? 0}
    
    var currentTime: CMTime {
        avPlayer?.currentTime() ?? .zero
    }
    
    private var playerItemBufferKeepUpObserver: NSKeyValueObservation?
    
    var onStart: (() -> Void) = { }
    var onFinish: (() -> Void) = { }
    
    var onPlay: (() -> Void) = { }
    var onPause: (() -> Void) = { }
    
    func seekToBegin() {
        avPlayer?.seek(to: .zero)
    }
    
    func seekTo(time: CMTime) {
        avPlayer?.seek(to: time)
    }
    
    func playFromBeginning() {
        seekToBegin()
        play()
        onPlay()
    }
    
    func backward() {
        var timeBackward = displayTimeSubject.value
        timeBackward -= 15
        avPlayer?.seek(to: CMTime(seconds: timeBackward, preferredTimescale: currentTime.timescale))
    }
    
    var getPercentComplete: Double {
        guard itemDurationSubject.value > 0 else { return 0 } // Handle cases where total duration is 0
        return (displayTimeSubject.value / itemDurationSubject.value) * 100
    }
    
    var isUnguidedPart: Bool {
        guard let unguidedSecond = track.unguidedSecond else {
            return false
        }
        return displayTimeSubject.value >= itemDurationSubject.value - unguidedSecond
    }
    
    /// Time observer.
    fileprivate var periodicTimeObserver: Any?
    
    var scrubState: PlayerScrubState = .reset {
        didSet {
            switch scrubState {
            case .reset:
                return
            case .scrubStarted:
                return
            case .scrubEnded(let seekTime):
                avPlayer?.seek(to: CMTime(seconds: seekTime, preferredTimescale: 1000))
            }
        }
    }
    
    init(track: Track) {
        self.track = track
        let playerItem = AVPlayerItem(url: track.streamURL!)
        self.avPlayer = AVPlayer(playerItem: playerItem)
        self.addPeriodicTimeObserver()
        self.addTimeControlStatusObserver()
        self.addItemDurationPublisher()
        startItemObserver()
        finishItemObserver()
    }
    
    func play() {
        self.avPlayer?.play()
        self.onPlay()
    }
    
    func destroy() {
        pause()
        avPlayer = nil
        removePeriodicTimeObserver()
        timeControlStatusKVOPublisher?.cancel()
        timeControlStatusKVOPublisher = nil
        itemDurationKVOPublisher?.cancel()
        itemDurationKVOPublisher = nil
        playerItemBufferKeepUpObserver = nil
        NotificationCenter.default.removeObserver(self)
    }
    
    func pause() {
        self.avPlayer?.pause()
        self.onPause()
    }
    
    private func startItemObserver() {
        playerItemBufferKeepUpObserver = avPlayer?.currentItem?.observe(\AVPlayerItem.isPlaybackLikelyToKeepUp, options: [.new]) { [weak self] _,_  in
            self?.onStart()
        }
    }
    
    private func finishItemObserver() {
        NotificationCenter.default.addObserver(forName: AVPlayerItem.didPlayToEndTimeNotification, object: avPlayer?.currentItem, queue: .main) { [weak self] _ in
            self?.onFinish()
        }
    }
    
    fileprivate func addPeriodicTimeObserver() {
        self.periodicTimeObserver = avPlayer?.addPeriodicTimeObserver(forInterval: time, queue: .main) { [weak self] (time) in
            guard let self = self else { return }
            
            // Always update observed time.
            self.observedTime = time.seconds
            
            switch self.scrubState {
            case .reset:
                displayTimeSubject.send(time.seconds)
            case .scrubStarted(let seekTime):
                // When scrubbing, the displayTime is bound to the Slider view, so
                // do not update it here.
                displayTimeSubject.send(seekTime)
            case .scrubEnded(let seekTime):
                self.scrubState = .reset
                displayTimeSubject.send(seekTime)
            }
        }
    }
    
    fileprivate func removePeriodicTimeObserver() {
        guard let periodicTimeObserver = self.periodicTimeObserver else {
            return
        }
        avPlayer?.removeTimeObserver(periodicTimeObserver)
        self.periodicTimeObserver = nil
    }
    
    fileprivate func addTimeControlStatusObserver() {
        timeControlStatusKVOPublisher = avPlayer?
            .publisher(for: \.timeControlStatus)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] (newStatus) in
                self?.timeControlStatus = newStatus
            })
    }
    
    fileprivate func addItemDurationPublisher() {
        itemDurationKVOPublisher = avPlayer?
            .publisher(for: \.currentItem?.duration)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] (newStatus) in
                guard let newStatus = newStatus else { return }
                self?.itemDurationSubject.send(newStatus.seconds)
            })
    }
}
