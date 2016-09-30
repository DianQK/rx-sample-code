//
//  Tool.swift
//  Stopwatch
//
//  Created by DianQK on 12/09/2016.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit

struct Tool {
    static let convertToTimeInfo: (TimeInterval) -> String = { ms in
        var form = DateFormatter()
        form.dateFormat = "mm:ss.SS"
        let date = Date(timeIntervalSince1970: ms)
        return form.string(from: date)
    }
    
    struct Color {
        static let red = UIColor(red: 252.0 / 255.0, green: 61.0 / 255.0, blue: 57.0 / 255.0, alpha: 1)
        static let green = UIColor(red: 83.0 / 255.0, green: 215.0 / 255.0, blue: 105.0 / 255.0, alpha: 1)
    }
}
