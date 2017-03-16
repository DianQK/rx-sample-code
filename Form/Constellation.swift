//
//  Constellation.swift
//  rx-sample-code
//
//  Created by DianQK on 14/03/2017.
//  Copyright © 2017 T. All rights reserved.
//

enum Constellation {

    case aries
    case taurus
    case gemini
    case cancer
    case leo
    case virgo
    case libra
    case scorpio
    case sagittarius
    case capricorn
    case aquarius
    case pisces

    var name: String {
        switch self {
        case .aries: return "牡羊座"
        case .taurus: return "金牛座"
        case .gemini: return "双子座"
        case .cancer: return "巨蟹座"
        case .leo: return "狮子座"
        case .virgo: return "处女座"
        case .libra: return "天秤座"
        case .scorpio: return "天蝎座"
        case .sagittarius: return "射手座"
        case .capricorn: return "摩羯座"
        case .aquarius: return "水瓶座"
        case .pisces: return "双鱼座"
        }
    }
    
}
