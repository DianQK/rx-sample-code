//
//  TimingViewModel.swift
//  Stopwatch
//
//  Created by DianQK on 12/09/2016.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxAutomaton
//import RxExtensions

struct TimingViewModel: StopwatchViewModelProtocol {
    
    let startAStopStyle: Observable<Style.Button>
    let resetALapStyle: Observable<Style.Button>
    let displayTime: Observable<String>
    let displayElements: Observable<[(title: Observable<String>, displayTime: Observable<String>, color: Observable<UIColor>)]>
    
    private enum Input {
        case start, stop, lap, reset
    }
    
    private enum State {
        case timing, stopped, reseted
    }
    
    private let automaton: Automaton<State, Input>
    
    private let disposeBag = DisposeBag()
    
    init(input: (startAStopTrigger: Observable<Void>, resetALapTrigger: Observable<Void>)) {
        
        let startAStopTrigger = input.startAStopTrigger.shareReplay(1)
        let resetALapTrigger = input.resetALapTrigger.shareReplay(1)
        
        let mappings: [Automaton<State, Input>.NextMapping] = [
        /*  Input  | fromState => toState                      |  Effect */
        /* --------------------------------------------------------------*/
            .start | [.reseted, .stopped].contains => .timing  | .empty(),
            .stop  | .timing                       => .stopped | .empty(),
            .reset | .stopped                      => .reseted | .empty(),
            ]
        
        let (inputSignal, inputObserver) = Observable<Input>.pipe()
        
        automaton = Automaton(state: .reseted, input: inputSignal, mapping: reduce(mappings), strategy: .latest)
        
        Observable.from([
            startAStopTrigger
                .withLatestFrom(automaton.state.asObservable())
                .map { state -> Input in
                    switch state {
                    case .reseted, .stopped: return .start
                    case .timing: return .stop
                    }
            },
            resetALapTrigger
                .withLatestFrom(automaton.state.asObservable())
                .flatMap { (state) -> Observable<Input> in
                    switch state {
                    case .reseted, .timing: return Observable.empty()
                    case .stopped: return Observable.just(.reset)
                    }
            }
            ])
            .merge()
            .subscribe(onNext: inputObserver.onNext)
            .disposed(by: disposeBag)
        
        let state = automaton.state.asObservable().shareReplay(1)
        
        resetALapStyle = state
            .map { state in
                switch state {
                case .reseted:
                    return Style.Button(title: "Lap", titleColor: UIColor.white, isEnabled: false, backgroungImage: #imageLiteral(resourceName: "gray"))
                case .stopped:
                    return Style.Button(title: "Reset", titleColor: UIColor.white, isEnabled: true, backgroungImage: #imageLiteral(resourceName: "gray"))
                case .timing:
                    return Style.Button(title: "Lap", titleColor: UIColor.white, isEnabled: true, backgroungImage: #imageLiteral(resourceName: "gray"))
                }
        }
        
        startAStopStyle = state
            .map { state in
                switch state {
                case .reseted:
                    return Style.Button(title: "Start", titleColor: Tool.Color.green, isEnabled: true, backgroungImage: #imageLiteral(resourceName: "green"))
                case .stopped:
                    return Style.Button(title: "Start", titleColor: Tool.Color.green, isEnabled: true, backgroungImage: #imageLiteral(resourceName: "green"))
                case .timing:
                    return Style.Button(title: "Stop", titleColor: Tool.Color.red, isEnabled: true, backgroungImage: #imageLiteral(resourceName: "red"))
                }
        }
        
        let timeInfo = automaton.state.asObservable()
            .flatMapLatest { state -> Observable<State> in
                switch state {
                case .reseted, .stopped:
                    return Observable.just(state)
                case .timing:
                    return Observable<Int>.interval(0.01, scheduler: MainScheduler.instance).map { _ in State.timing }
                }
            }
            .scan((time: 0, state: State.reseted)) { (acc, x) -> (time: TimeInterval, state: State) in
                switch x {
                case .reseted: return (time: 0, state: x)
                case .stopped: return (time: acc.time, state: x)
                case .timing: return (time: acc.time + 0.01, state: x)
                }
            }
            .shareReplay(1)
        
        displayTime = timeInfo
            .map { $0.time }
            .map(Tool.convertToTimeInfo)
        
        let lap = Observable.from([
            resetALapTrigger,
            automaton.state.asObservable()
                .scan((pre: State.reseted, current: State.reseted)) { acc, x in
                    (pre: acc.current, current: x)
                }
                .flatMap { state -> Observable<Void> in
                    if state.pre == .reseted && state.current == .timing {
                        return Observable.just(())
                    } else {
                        return Observable.empty()
                    }
                }
                .delay(0.001, scheduler: MainScheduler.instance)
            ])
            .merge()
        
        displayElements = timeInfo
            .sample(lap)
            .scan((preTime: 0, info: [(lap: String, time: Observable<TimeInterval>)]())) { (acc, x) -> (preTime: TimeInterval, info: [(lap: String, time: Observable<TimeInterval>)]) in
                switch x.state {
                case .reseted:
                    return (preTime: 0, info: [])
                case .timing, .stopped:
                    let info = [(lap: "Lap \(acc.info.count + 1)", time: Observable.just(x.time))] + acc.info
                    return (preTime: x.time, info: info)
                }
            }
            .map { $0.info.map { element in
                return (
                    title: Observable.just(element.lap),
                    displayTime: element.time.map(Tool.convertToTimeInfo),
                    color: Observable.just(UIColor.white)
                )
            }
        }
    }
}
