//
//  NewFeedVoiceRecordViewController.swift
//  Yep
//
//  Created by nixzhu on 15/11/25.
//  Copyright © 2015年 Catch Inc. All rights reserved.
//

import UIKit
import AVFoundation
import RxSwift
import RxCocoa
import RxAutomaton

struct FeedVoice {
    
    let fileURL: URL
    let sampleValuesCount: Int
    let limitedSampleValues: [CGFloat]
}

let allowAll: ((Any) -> Bool) = { _ in
    return true
}

func empty<T>() -> ((T) -> Void) {
    return { _ in
    }
}

struct Message {
    public var imageFileURL: URL?
    public var videoFileURL: URL?
}

final class NewFeedVoiceRecordViewController: UIViewController {

    @IBOutlet private weak var cancelButton: UIBarButtonItem!
    @IBOutlet private weak var nextButton: UIBarButtonItem!

    @IBOutlet private weak var voiceRecordSampleView: VoiceRecordSampleView!
    @IBOutlet private weak var voiceIndicatorImageView: UIImageView!
    @IBOutlet private weak var voiceIndicatorImageViewCenterXConstraint: NSLayoutConstraint!

    @IBOutlet private weak var timeLabel: UILabel!

    @IBOutlet private weak var voiceRecordButton: RecordButton!
    @IBOutlet private weak var playButton: UIButton!
    @IBOutlet private weak var resetButton: UIButton!

    private var sampleValues: Variable<[CGFloat]> = Variable([])

    private var audioPlayedDuration: TimeInterval = 0 {
        willSet {
            guard newValue != audioPlayedDuration else {
                return
            }

            let sampleStep: CGFloat = (4 + 2)
            let fullWidth = voiceRecordSampleView.bounds.width

            let fullOffsetX = CGFloat(sampleValues.value.count) * sampleStep

            let currentOffsetX = CGFloat(newValue) * (10 * sampleStep)

            // 0.5 用于回去
            let duration: TimeInterval = newValue > audioPlayedDuration ? 0.02 : 0.5

            if fullOffsetX > fullWidth {

                if currentOffsetX <= fullWidth * 0.5 {
                    UIView.animate(withDuration: duration, delay: 0.0, options: .curveLinear, animations: { [weak self] in
                        self?.voiceIndicatorImageViewCenterXConstraint.constant = -fullWidth * 0.5 + 2 + currentOffsetX
                        self?.view.layoutIfNeeded()
                    }, completion: nil)
                } else {
                    voiceRecordSampleView.sampleCollectionView.setContentOffset(CGPoint(x: currentOffsetX - fullWidth * 0.5 , y: 0), animated: false)
                }

            } else {
                UIView.animate(withDuration: duration, delay: 0.0, options: .curveLinear, animations: { [weak self] in
                    self?.voiceIndicatorImageViewCenterXConstraint.constant = -fullWidth * 0.5 + 2 + currentOffsetX
                    self?.view.layoutIfNeeded()
                }, completion: nil)
            }
        }
    }

    private var feedVoice: FeedVoice?

    deinit {
        print("deinit NewFeedVoiceRecord")
    }

    private let disposeBag = DisposeBag()

    private enum State {
        case reset, recording, recorded, playing, playPausing, canceled, playStopped
    }

    private enum Input {
        case record, stop, play, pause, reset, cancel, playCompleted
    }

    private let mappings: [Automaton<State, Input>.NextMapping] = [
    /*  Input          | fromState                                                   => toState       |  Effect */
    /* ---------------------------------------------------------------------------------------------------------*/
        .record        | (.reset                                                     => .recording)   | .empty(),
        .stop   /* stopRecording */     | (.recording                                                 => .recorded)    | .empty(),
        .play          | ([.recorded, .playPausing, .playStopped].contains           => .playing)     | .empty(),
        .pause  /* pausePlaying */        | (.playing                                                   => .playPausing) | .empty(), // 这里不是 empty ，有一个自动转换，从 playing => playStopped
        .reset         | ([.recorded, .playing, .playPausing, .playStopped].contains => .reset)       | .empty(),
        .cancel /* 移除 cancel */    | (allowAll                                                   => .canceled)    | .empty(),
        .playCompleted  /* stopPlaying */ | (.playing                                                   => .playStopped) | .empty() // 当然从 playing -> playStopped 也可以手动停止
    ]
    
    private let (inputSignal, inputObserver) = Observable<Input>.pipe()
    
    private lazy var automaton: Automaton<State, Input> = Automaton(state: .reset, input: self.inputSignal, mapping: reduce(self.mappings), strategy: .latest)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            Observable.from([
                voiceRecordButton.rx.tap.withLatestFrom(automaton.state.asObservable())
                    .map { (state) in
                        switch state {
                        case .recording:
                            return Input.stop
                        case .reset:
                            return Input.record
                        default:
                            fatalError()
                        }
                },
                resetButton.rx.tap.map { Input.reset },
                playButton.rx.tap.withLatestFrom(automaton.state.asObservable())
                    .map { (state) in
                        switch state {
                        case .playing:
                            return Input.pause
                        case .playPausing, .recorded, .playStopped:
                            return Input.play
                        default:
                            fatalError()
                        }
                },
                cancelButton.rx.tap.map { Input.cancel }
                ])
                .merge()
                .bindTo(inputObserver)
                .disposed(by: disposeBag)
        }
        
        do {
            automaton.state.asObservable()
                .subscribe(onNext: { [weak self] (state) in
                    guard let `self` = self else { return }
                    switch state {
                    case .recording:
                        proposeToAccess(.microphone, agreed: {
                            do {
                                let decibelSamplePeriodicReport: AudioBot.PeriodicReport = (reportingFrequency: 10, report: { decibelSample in
                                    DispatchQueue.main.async {
                                        let value = CGFloat(decibelSample)
                                        self.sampleValues.value.append(value)
                                        self.voiceRecordSampleView.appendSampleValue(value: value)
                                    }
                                })
                                AudioBot.mixWithOthersWhenRecording = true
                                try AudioBot.startRecordAudioToFileURL(nil, forUsage: .normal, withDecibelSamplePeriodicReport: decibelSamplePeriodicReport)
                                
                                self.nextButton.isEnabled = false
                                
                                self.voiceIndicatorImageView.alpha = 0
                                
                                UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
                                    self.voiceRecordButton.alpha = 1
                                    self.voiceRecordButton.appearance = .recording
                                    
                                    self.playButton.alpha = 0
                                    self.resetButton.alpha = 0
                                    }, completion: nil)
                                
                            } catch let error {
                                print("record error: \(error)")
                            }
                            }, rejected: { [weak self] in
                                self?.alertCanNotAccessMicrophone()
                            })
                    case .recorded:
                        AudioBot.stopRecord { fileURL, duration, decibelSamples in
                            guard duration > YepConfig.AudioRecord.shortestDuration else {
                                YepAlert.alertSorry(message: "Voice recording time is too short!", inViewController: self, withDismissAction: {
                                    self.inputObserver.onNext(.reset)
                                    })
                                return
                            }
                            
                            let compressedDecibelSamples = AudioBot.compressDecibelSamples(decibelSamples, withSamplingInterval: 1, minNumberOfDecibelSamples: 10, maxNumberOfDecibelSamples: 50)
                            let feedVoice = FeedVoice(fileURL: fileURL, sampleValuesCount: decibelSamples.count, limitedSampleValues: compressedDecibelSamples.map({ CGFloat($0) }))
                            self.feedVoice = feedVoice
                            
                            self.nextButton.isEnabled = true
                            
                            self.voiceIndicatorImageView.alpha = 0
                            
                            UIView.animate(withDuration: 0.25, delay: 0.0, options: UIViewAnimationOptions(), animations: {
                                self.voiceRecordButton.alpha = 0
                                self.playButton.alpha = 1
                                self.resetButton.alpha = 1
                                }, completion: nil)
                            
                            let fullWidth = self.voiceRecordSampleView.bounds.width
                            
                            if !self.voiceRecordSampleView.sampleValues.isEmpty {
                                let firstIndexPath = IndexPath(item: 0, section: 0)
                                self.voiceRecordSampleView.sampleCollectionView.scrollToItem(at: firstIndexPath, at: .left, animated: true)
                            }
                            
                            UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
                                self.voiceIndicatorImageView.alpha = 1
                                }, completion: { _ in
                                    UIView.animate(withDuration: 0.75, delay: 0.0, options: .curveEaseInOut, animations: {
                                        self.voiceIndicatorImageViewCenterXConstraint.constant = -fullWidth * 0.5 + 2
                                        self.view.layoutIfNeeded()
                                        }, completion: { _ in })
                            })
                        }
                    case .playing:
                        guard let fileURL = self.feedVoice?.fileURL else {
                            return
                        }
                        do {
                            let progressPeriodicReport: AudioBot.PeriodicReport = (reportingFrequency: 60, report: { progress in
                                //print("progress: \(progress)")
                            })
                            
                            try AudioBot.startPlayAudioAtFileURL(fileURL, fromTime: self.audioPlayedDuration, withProgressPeriodicReport: progressPeriodicReport, finish: { success in
                                
                                self.audioPlayedDuration = 0
                                
                                if success {
                                    self.inputObserver.onNext(.playCompleted)
                                }
                                })
                            
                            AudioBot.reportPlayingDuration = { duration in
                                self.audioPlayedDuration = duration
                            }
                            
                            self.playButton.setImage(R.image.button_voice_pause(), for: .normal)
                            
                        } catch let error {
                            print("AudioBot: \(error)")
                        }
                    case .reset:
                        do {
                            if let audioPlayer = YepAudioService.shared.audioPlayer , audioPlayer.isPlaying {
                                audioPlayer.pause()
                            }
                            AudioBot.stopPlay()
                            
                            self.voiceRecordSampleView.reset()
                            self.sampleValues.value = []
                            
                            self.playButton.setImage(R.image.button_voice_play(), for: .normal)
                            self.audioPlayedDuration = 0
                        }
                        
                        self.nextButton.isEnabled = false
                        
                        self.voiceIndicatorImageView.alpha = 0
                        
                        UIView.animate(withDuration: 0.25, delay: 0.0, options: UIViewAnimationOptions(), animations: {
                            self.voiceRecordButton.alpha = 1
                            self.voiceRecordButton.appearance = .default
                            
                            self.playButton.alpha = 0
                            self.resetButton.alpha = 0
                            }, completion: nil)
                        
                        self.voiceIndicatorImageViewCenterXConstraint.constant = 0
                        self.view.layoutIfNeeded()
                    case .playPausing:
                        AudioBot.pausePlay()
                        self.playButton.setImage(R.image.button_voice_play(), for: .normal)
                    case .canceled:
                        AudioBot.stopPlay()
                        self.dismiss(animated: true) {
                            AudioBot.stopRecord(empty())
                        }
                    case .playStopped:
                        self.playButton.setImage(R.image.button_voice_play(), for: .normal)
                    }
                })
                .disposed(by: disposeBag)
            
            sampleValues.asObservable()
                .map { $0.count }
                .map { (count) -> String in
                    let frequency = 10
                    let minutes = count / frequency / 60
                    let seconds = count / frequency - minutes * 60
                    let subSeconds = count - seconds * frequency - minutes * 60 * frequency
                    return String(format: "%02d:%02d.%d", minutes, seconds, subSeconds)
                }
                .bindTo(timeLabel.rx.text)
                .disposed(by: disposeBag)
        }
        
    }

}
