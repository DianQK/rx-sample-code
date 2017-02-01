//
//  AVAudioSession+AudioBot.swift
//  VoiceMemo
//
//  Created by NIX on 16/7/27.
//  Copyright © 2016年 nixWork. All rights reserved.
//

import Foundation
import AVFoundation

extension AVAudioSession {

    var audiobot_canPlay: Bool {

        switch category {
        case AVAudioSessionCategoryPlayback:
            return true
        case AVAudioSessionCategoryPlayAndRecord:
            return true
        default:
            return false
        }
    }
}

