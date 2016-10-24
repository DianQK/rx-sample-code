//
//  Config.swift
//  Expandable
//
//  Created by DianQK on 8/18/16.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit

struct Config<View> {
    let view: View
    init(_ view: View) {
        self.view = view
    }
}

extension NSObjectProtocol {
    var config: Config<Self> {
        return Config(self)
    }
}

extension Config where View: DateFormatter {
    var longStyle: Config {
        view.dateStyle = DateFormatter.Style.long
        return self
    }
    
    var string: (Date) -> String {
        return view.string
    }
}
