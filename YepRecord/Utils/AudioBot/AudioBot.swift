//
//  AudioBot.swift
//  AudioBot
//
//  Created by NIX on 15/11/28.
//  Copyright © 2015年 nixWork. All rights reserved.
//

import Foundation
import AVFoundation

open class AudioBot: NSObject {

    open static var mixWithOthersWhenRecording: Bool = false

    fileprivate override init() {
        super.init()
    }
    fileprivate static let shared = AudioBot()

    fileprivate var audioRecorder: AVAudioRecorder?
    fileprivate var audioPlayer: AVAudioPlayer?

    open static var recording: Bool {
        return shared.audioRecorder?.isRecording ?? false
    }

    open static var recordingFileURL: URL? {
        return shared.audioRecorder?.url
    }

    open static var playing: Bool {
        return shared.audioPlayer?.isPlaying ?? false
    }

    open static var playingFileURL: URL? {
        return shared.audioPlayer?.url
    }

    open static var reportRecordingDuration: ((_ duration: TimeInterval) -> Void)?
    open static var reportPlayingDuration: ((_ duration: TimeInterval) -> Void)?

    fileprivate var recordingTimer: Timer?
    fileprivate var playingTimer: Timer?

    public enum BotError: Error {

        case invalidReportingFrequency
        case noFileURL
    }

    public typealias PeriodicReport = (reportingFrequency: TimeInterval, report: (_ value: Float) -> Void)

    fileprivate var recordingPeriodicReport: PeriodicReport?
    fileprivate var playingPeriodicReport: PeriodicReport?

    fileprivate var playingFinish: ((Bool) -> Void)?

    fileprivate var decibelSamples: [Float] = []

    fileprivate func clearForRecording() {

        AudioBot.reportRecordingDuration = nil

        recordingTimer?.invalidate()
        recordingTimer = nil

        recordingPeriodicReport = nil

        decibelSamples = []
    }

    fileprivate func clearForPlaying(_ finish: Bool) {

        AudioBot.reportPlayingDuration = nil

        playingTimer?.invalidate()
        playingTimer = nil

        if finish {
            playingPeriodicReport?.report(0)
        }
        playingPeriodicReport = nil
    }

    fileprivate func deactiveAudioSessionAndNotifyOthers() {

        _ = try? AVAudioSession.sharedInstance().setActive(false, with: .notifyOthersOnDeactivation)
    }
}

// MARK: - Record

public extension AudioBot {

    public enum Usage {

        case normal
        case custom(settings: [String: Any])

        var settings: [String: Any] {

            switch self {

            case .normal:
                return [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVEncoderAudioQualityKey : AVAudioQuality.medium.rawValue,
                    AVEncoderBitRateKey : 64000,
                    AVNumberOfChannelsKey: 2,
                    AVSampleRateKey : 44100.0
                ]

            case .custom(let settings):
                return settings
            }
        }
    }

    public class func startRecordAudioToFileURL(_ fileURL: URL?, forUsage usage: Usage, withDecibelSamplePeriodicReport decibelSamplePeriodicReport: PeriodicReport) throws {

        stopPlay()

        do {
            if mixWithOthersWhenRecording {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord, with: [.mixWithOthers, .defaultToSpeaker])
            } else {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryRecord)
            }

            try AVAudioSession.sharedInstance().setActive(true)

        } catch let error {
            throw error
        }

        if let audioRecorder = shared.audioRecorder , audioRecorder.isRecording {

            audioRecorder.stop()

            // TODO: delete previews record file?
        }

        guard let fileURL = (fileURL ?? FileManager.audiobot_audioFileURLWithName(name: UUID().uuidString)) else {
            throw BotError.noFileURL
        }

        guard decibelSamplePeriodicReport.reportingFrequency > 0 else {
            throw BotError.invalidReportingFrequency
        }

        let settings = usage.settings

        do {
            let audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
            shared.audioRecorder = audioRecorder

            audioRecorder.delegate = shared
            audioRecorder.isMeteringEnabled = true
            audioRecorder.prepareToRecord()

        } catch let error {
            throw error
        }

        shared.audioRecorder?.record()

        shared.recordingPeriodicReport = decibelSamplePeriodicReport

        let timeInterval = 1 / decibelSamplePeriodicReport.reportingFrequency
        let timer = Timer.scheduledTimer(timeInterval: timeInterval, target: shared, selector: #selector(AudioBot.reportRecordingDecibel(_:)), userInfo: nil, repeats: true)
        shared.recordingTimer?.invalidate()
        shared.recordingTimer = timer
    }

    @objc fileprivate func reportRecordingDecibel(_ sender: Timer) {

        guard let audioRecorder = audioRecorder else {
            return
        }

        audioRecorder.updateMeters()

        let normalizedDecibel = pow(10, audioRecorder.averagePower(forChannel: 0) * 0.05)

        recordingPeriodicReport?.report(normalizedDecibel)

        decibelSamples.append(normalizedDecibel)

        AudioBot.reportRecordingDuration?(audioRecorder.currentTime)
    }

    public class func stopRecord(_ finish: (_ fileURL: URL, _ duration: TimeInterval, _ decibelSamples: [Float]) -> Void) {

        defer {
            shared.clearForRecording()
        }

        guard let audioRecorder = shared.audioRecorder , audioRecorder.isRecording else {
            return
        }

        let duration = audioRecorder.currentTime

        audioRecorder.stop()

        finish(audioRecorder.url, duration, shared.decibelSamples)
    }

    public class func removeAudioAtFileURL(_ fileURL: URL) {

        FileManager.audiobot_removeAudioAtFileURL(fileURL: fileURL)
    }

    public class func compressDecibelSamples(_ decibelSamples: [Float], withSamplingInterval samplingInterval: Int, minNumberOfDecibelSamples: Int, maxNumberOfDecibelSamples: Int) -> [Float] {

        guard samplingInterval > 0 else {
            fatalError("Invlid samplingInterval!")
        }
        guard minNumberOfDecibelSamples > 0 else {
            fatalError("Invlid minNumberOfDecibelSamples!")
        }
        guard maxNumberOfDecibelSamples >= minNumberOfDecibelSamples else {
            fatalError("Invlid maxNumberOfDecibelSamples!")
        }

        guard decibelSamples.count >= minNumberOfDecibelSamples else {
            print("Warning: Insufficient number of decibelSamples!")
            return decibelSamples
        }

        func f(_ x: Int, max: Int) -> Int {
            let n = 1 - 1 / exp(Double(x) / 100)
            return Int(Double(max) * n)
        }

        let realSamplingInterval = min(samplingInterval, decibelSamples.count / minNumberOfDecibelSamples)
        var samples: [Float] = []
        var i = 0
        while i < decibelSamples.count {
            samples.append(decibelSamples[i])
            i += realSamplingInterval
        }

        let finalNumber = f(samples.count, max: maxNumberOfDecibelSamples)

        func averageSamplingFrom(_ values: [Float], withCount count: Int) -> [Float] {

            let step = Double(values.count) / Double(count)

            var outputValues = [Float]()

            var x: Double = 0

            for _ in 0..<count {

                let index = Int(x)

                if index < values.count {
                    let value = values[index]
                    let fixedValue = Float(Int(value * 100)) / 100 // 最多两位小数
                    outputValues.append(fixedValue)

                } else {
                    break
                }

                x += step
            }

            return outputValues
        }

        let compressedDecibelSamples = averageSamplingFrom(samples, withCount: finalNumber)

        return compressedDecibelSamples
    }
}

// MARK: - Playback

public extension AudioBot {

    public class func startPlayAudioAtFileURL(_ fileURL: URL, fromTime: TimeInterval, withProgressPeriodicReport progressPeriodicReport: PeriodicReport, finish: @escaping ((Bool) -> Void)) throws {

        stopRecord { _, _, _ in }

        if !AVAudioSession.sharedInstance().audiobot_canPlay {
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                try AVAudioSession.sharedInstance().setActive(true)
            } catch let error {
                throw error
            }
        }

        guard progressPeriodicReport.reportingFrequency > 0 else {
            throw BotError.invalidReportingFrequency
        }

        if let audioPlayer = shared.audioPlayer , audioPlayer.url == fileURL {
            audioPlayer.play()

        } else {
            shared.audioPlayer?.pause()

            do {
                let audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
                shared.audioPlayer = audioPlayer

                audioPlayer.delegate = shared
                audioPlayer.prepareToPlay()
                audioPlayer.currentTime = fromTime
                audioPlayer.play()

            } catch let error {
                throw error
            }
        }

        shared.playingPeriodicReport = progressPeriodicReport
        shared.playingFinish = finish

        let timeInterval = 1 / progressPeriodicReport.reportingFrequency
        let timer = Timer.scheduledTimer(timeInterval: timeInterval, target: shared, selector: #selector(AudioBot.reportPlayingProgress(_:)), userInfo: nil, repeats: true)
        shared.playingTimer?.invalidate()
        shared.playingTimer = timer
    }

    @objc fileprivate func reportPlayingProgress(_ sender: Timer) {

        guard let audioPlayer = audioPlayer else {
            return
        }

        let progress = audioPlayer.currentTime / audioPlayer.duration

        playingPeriodicReport?.report(Float(progress))

        AudioBot.reportPlayingDuration?(audioPlayer.currentTime)
    }

    public class func pausePlay() {

        shared.clearForPlaying(false)

        shared.audioPlayer?.pause()

        shared.deactiveAudioSessionAndNotifyOthers()
    }

    public class func stopPlay() {

        shared.clearForPlaying(true)

        shared.audioPlayer?.stop()

        shared.playingFinish?(false)
        shared.playingFinish = nil

        shared.deactiveAudioSessionAndNotifyOthers()
    }
}

// MARK: - AVAudioRecorderDelegate

extension AudioBot: AVAudioRecorderDelegate {

    public func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {

        print("AudioBot audioRecorderDidFinishRecording: \(flag)")
    }

    public func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {

        print("AudioBot audioRecorderEncodeErrorDidOccur: \(String(describing: error))")

        if let fileURL = AudioBot.recordingFileURL {
            AudioBot.removeAudioAtFileURL(fileURL)
        }

        clearForRecording()
    }
}

// MARK: - AVAudioPlayerDelegate

extension AudioBot: AVAudioPlayerDelegate {

    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {

        print("AudioBot audioPlayerDidFinishPlaying: \(flag)")

        clearForPlaying(true)
        playingFinish?(true)
        playingFinish = nil

        deactiveAudioSessionAndNotifyOthers()
    }

    public func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {

        print("AudioBot audioPlayerDecodeErrorDidOccur: \(String(describing: error))")

        clearForPlaying(true)
        playingFinish?(false)
        playingFinish = nil

        deactiveAudioSessionAndNotifyOthers()
    }
}

