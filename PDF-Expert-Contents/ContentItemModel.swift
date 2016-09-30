//
//  ContentItemModel.swift
//  PDF-Expert-Contents
//
//  Created by DianQK on 24/09/2016.
//  Copyright © 2016 DianQK. All rights reserved.
//

import Foundation
import RxDataSources
import SwiftyJSON
import RxExtensions

typealias ExpandableContentItemModel = ExpandableItem<ContentItemModel>

struct ContentItemModel: IDHashable, IdentifiableType {

    let id: Int64
    let title: String
    let level: Int
    let url: URL?

    init(title: String, level: Int, id: Int64, url: URL?) {
        self.title = title
        self.level = level
        self.id = id
        self.url = url
    }

    var hashValue: Int {
        return id.hashValue
    }

    var identity: Int64 {
        return id
    }

    static func createExpandableContentItemModel(json: JSON, withPreLevel preLevel: Int) -> ExpandableContentItemModel {
        let title = json["title"].stringValue
        let id = json["id"].int64Value
        let url = URL(string: json["url"].stringValue)

        let level = preLevel + 1

        let subItems: [ExpandableContentItemModel]

        if let subJSON = json["subdirectory"].array, !subJSON.isEmpty {
            subItems = subJSON.map { createExpandableContentItemModel(json: $0, withPreLevel: level) }
        } else {
            subItems = []
        }
        let contentItemModel = ContentItemModel(title: title, level: level, id: id, url: url)
        let expandableItem = ExpandableItem(model: contentItemModel, isExpanded: false, subItems: subItems)
        return expandableItem
    }
}
