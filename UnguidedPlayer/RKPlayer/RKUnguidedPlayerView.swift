//
// RKUnguidedPlayerView.swift
//
// Created by Reza Khonsari on 12/7/24.
// Copyright © 2024 Reza Khonsari. All rights reserved.
//
// Linkedin: https://www.linkedin.com/in/rezakhonsari-ios/
// Github: https://github.com/rezamagnet
//

import SwiftUI
import AVFoundation
import MediaPlayer
import AVKit
import Combine

public struct RKUnguidedPlayerView: View {
    
    @ObservedObject public var viewModel: RKUnguidedPlayerViewModel
    
    @State var speakerButtonState: SpeakerButtonState = .unmute
    @State var fadeTimer = Constants.timer
    @State var fadeInOpacity: Double = 1
    @State private var backgroundPlayerOpacity: Double = 0
    
    public init(viewModel: RKUnguidedPlayerViewModel) {
        self.viewModel = viewModel
    }
    
    var likeButtonView: some View {
        Button(action: {
            viewModel.trackFavoritedAction()
            startFadeAnimation()
        }) {
            
            Image(systemName: viewModel.trackFavorited ? "heart.fill" : "heart" )
                .foregroundStyle(.blue)
                .font(.headline)
                .padding()
                .contentTransition(.symbolEffect(.replace))
        }
        .buttonStyle(.plain)
    }
    
    var playButtonView: some View {
        Button(action: {
            viewModel.playAction()
            fadeInOpacity = 1
        }) {
            
            Image(systemName: viewModel.isPlaying && !viewModel.isFinished ? "pause.fill" : "play.fill")
                .foregroundColor(.white)
                .font(.largeTitle)
                .frame(width: 80, height: 80)
                .background(.white.opacity(0.3))
                .clipShape(Circle())
                .contentTransition(.symbolEffect(.replace))
        }
        .buttonStyle(.plain)
    }
    
    var skipButtonView: some View {
        Button(action: {
            dismissPlayer()
        }) {
            HStack {
                Text("Skip")
                Image(.skip)
            }
            .font(.custom(Constants.fontName, size: 16))
            .foregroundColor(.white)
            .frame(width: 83, height: 35)
            .background(.white.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
    
    @State var isRewinded = false
    
    var backwardButtonView: some View {
        Button(action: {
            viewModel.rewindAction()
            withAnimation {
                isRewinded.toggle()
            }
        }) {
            Image(systemName: "gobackward.15")
                .foregroundColor(.white)
                .font(.headline)
                .padding()
                .symbolEffect(.bounce, value: isRewinded)
        }
        .buttonStyle(.plain)
    }
    
    var speakerView: some View {
        Button(action: {
            if speakerButtonState == .mute {
                viewModel.unmute()
            } else {
                viewModel.mute()
            }
            withAnimation {
                speakerButtonState = speakerButtonState.toggle()
                startFadeAnimation()
            }
        }) {
            Image(systemName: speakerButtonState.rawValue)
                .foregroundColor(.white)
                .font(.headline)
                .contentTransition(.symbolEffect(.replace))
        }
        .buttonStyle(.plain)
    }
    
    private func dismissPlayer() {
        viewModel.destroyAll()
    }
    
    @ViewBuilder
    func controlButtons() -> some View {
        HStack(alignment: .center, spacing: 32) {
            speakerView
                .frame(width: 20, height: 20)

            backwardButtonView
            
            Spacer()
            
            likeButtonView
            
            Spacer()
                .frame(width: 20, height: 20)
        }
    }
    
    func startFadeAnimation() {
        fadeInOpacity = 1
        fadeTimer = Constants.timer
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                // Background Video RKPlayer
                
                if viewModel.backgroundPlayer != nil {
                    VideoPlayerView(player: $viewModel.backgroundPlayer, isAudioPlayed: $viewModel.isPlaying) {
                        backgroundPlayerOpacity = 1
                    }
                    .opacity(backgroundPlayerOpacity)
                    .ignoresSafeArea()
                    .disabled(true)
                    
                    VideoPlayerView(player: $viewModel.noisePlayer, isAudioPlayed: $viewModel.isPlaying) { }
                        .opacity(0)
                        .ignoresSafeArea()
                        .disabled(true)
                }
                
                // Gradient Overlay (Clear to Black)
                VStack {
                    Spacer()
                    Rectangle()
                        .foregroundColor(.clear)
                        .background(LinearGradient(gradient: Gradient(colors: [.clear, .black]), startPoint: .top, endPoint: .bottom))
                        .edgesIgnoringSafeArea(.bottom)
                        .frame(height: UIScreen.main.bounds.height / 1.5)
                }
                
                VStack(alignment: .leading) {
                    Spacer()
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text(viewModel.displayTitle)
                                .foregroundColor(.white)
                                .font(.custom(Constants.fontName, size: 32))
                                .fontWeight(.bold)
                                .padding(.bottom, 8)
                                .multilineTextAlignment(.leading)
                            if viewModel.isUnguidedPart {
                                Spacer()
                                skipButtonView
                            }
                        }
                        
                        Text(viewModel.track.subtitle ?? "No track subtitle")
                            .foregroundColor(.white)
                            .font(.custom(Constants.fontName, size: 20))
                            .fontWeight(.medium)
                            .padding(.bottom, 30)
                    }
                    .padding(.horizontal)
                    
                    VStack {
                        ZStack(alignment: .leading) {
                            Group {
                                if viewModel.isPlayerDurationMoreThanZero {
                                    SliderView(
                                        value: $viewModel.displayTime,
                                        in: 0...viewModel.itemDuration,
                                        unguidedSecond: viewModel.track.unguidedSecond ?? 0
                                    ) { isScrubStarted in
                                        if isScrubStarted {
                                            viewModel.updateScrub(.scrubStarted(viewModel.displayTime))
                                            fadeInOpacity = 1
                                            
                                        } else {
                                            viewModel.updateScrub(.scrubEnded(viewModel.displayTime))
                                            startFadeAnimation()
                                            
                                        }
                                    }
                                    .frame(height: 10)
                                } else {
                                    SliderView(value: $viewModel.displayTime, in: 0...0) { _ in }
                                        .frame(height: 10)
                                }
                            }
                            .offset(y: -4)
                            .foregroundStyle(Color.accentColor)
                        }
                        .padding(.horizontal)
                        
                        HStack {
                            Text(viewModel.displayTimeFormattedText)
                            Spacer()
                            if viewModel.isPlayerDurationMoreThanZero {
                                Text(viewModel.displayItemDurationFormattedText)
                                    .foregroundStyle(viewModel.isUnguidedPart ? .green : .white)
                            }
                        }
                        .foregroundStyle(.white)
                        .font(.custom(Constants.fontName, size: 12))
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 20)
                    
                    controlButtons()
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                        .onAppear {
                            viewModel.appearAction()
                        }
                }
                .opacity(fadeInOpacity)
            }
            .overlay(alignment: .centerLastTextBaseline) {
                playButtonView
            }
            .simultaneousGesture(TapGesture()
                .onEnded({ _ in
                    startFadeAnimation()
                }))
        }
        .onReceive(fadeTimer) { _ in
            if fadeInOpacity != 0 && viewModel.isPlaying {
                withAnimation {
                    fadeInOpacity = 0
                }
            }
        }
        
    }
}

extension RKUnguidedPlayerView {
    struct Constants {
        static let timer = Timer.publish(every: 3, on: .current, in: .common).autoconnect()
        static let fontName = "Helvetica Neue"
    }
    
    enum SpeakerButtonState: String {
        
        case mute = "speaker.slash.fill"
        case unmute = "speaker.fill"
        
        func toggle() -> SpeakerButtonState {
            self == .mute ? .unmute : .mute
        }
    }
}
