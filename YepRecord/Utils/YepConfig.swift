//
//  YepConfig.swift
//  Yep
//
//  Created by NIX on 15/3/17.
//  Copyright (c) 2015年 Catch Inc. All rights reserved.
//

import UIKit

let avatarFadeTransitionDuration: TimeInterval = 0.0
let bigAvatarFadeTransitionDuration: TimeInterval = 0.15
let imageFadeTransitionDuration: TimeInterval = 0.2

final class YepConfig {

    static let minMessageTextLabelWidth: CGFloat = 20.0

    static let minMessageSampleViewWidth: CGFloat = 25.0

    static let skillHomeHeaderViewHeight: CGFloat = 114.0

    static let skillHomeHeaderButtonHeight: CGFloat = 50.0

    static let maxFeedTextLength: Int = 300

    static let termsURLString = "http://privacy.soyep.com"
    static let appURLString = "itms-apps://itunes.apple.com/app/id" + "983891256"

    static let forcedHideActivityIndicatorTimeInterval: TimeInterval = 30

    static let dismissKeyboardDelayTimeInterval : TimeInterval = 0.45

    struct Notification {
        static let OAuthResult = "YepConfig.Notification.OAuthResult"
        static let createdFeed = "YepConfig.Notification.createdFeed"
        static let deletedFeed = "YepConfig.Notification.deletedFeed"
        static let switchedToOthersFromContactsTab = "YepConfig.Notification.switchedToOthersFromContactsTab"
        static let blockedFeedsByCreator = "YepConfig.Notification.blockedFeedsByCreator"
    }

    class func getScreenRect() -> CGRect {
        return UIScreen.main.bounds
    }

    class func verifyCodeLength() -> Int {
        return 4
    }

    class func callMeInSeconds() -> Int {
        return 60
    }

    class func avatarMaxSize() -> CGSize {
        return CGSize(width: 414, height: 414)
    }

    class func chatCellAvatarSize() -> CGFloat {
        return 40.0
    }

    class func chatCellGapBetweenTextContentLabelAndAvatar() -> CGFloat {
        return 23
    }

    class func chatCellGapBetweenWallAndAvatar() -> CGFloat {
        return 15
    }

    class func chatTextGapBetweenWallAndContentLabel() -> CGFloat {
        return 50
    }

    class func messageImageCompressionQuality() -> CGFloat {
        return 0.95
    }

    class func audioSampleWidth() -> CGFloat {
        return 2
    }

    class func audioSampleGap() -> CGFloat {
        return 1
    }

    class func editProfileAvatarSize() -> CGFloat {
        return 100
    }

    struct AudioRecord {
        static let shortestDuration: TimeInterval = 1.0
        static let longestDuration: TimeInterval = 60
    }


    struct Settings {
        static let userCellAvatarSize: CGFloat = 80

        static let introFont: UIFont = {
            return UIFont.systemFont(ofSize: 12, weight: UIFontWeightLight)
        }()

        static let introInset: CGFloat = 20 + userCellAvatarSize + 20 + 10 + 11 + 20
    }

    struct EditProfile {

        static let infoFont = UIFont.systemFont(ofSize: 15, weight: UIFontWeightLight)
        static let infoInset: CGFloat = 20 + 20
    }

    struct ContactsCell {
        static let separatorInset = UIEdgeInsets(top: 0, left: 85, bottom: 0, right: 0)
    }

    struct SearchTableView {
        static let separatorColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1)
        static let backgroundColor = UIColor(red: 250/255.0, green: 250/255.0, blue: 250/255.0, alpha: 1)
    }

    struct ConversationCell {
        static let avatarSize: CGFloat = 60
    }

    struct FeedMedia {
        static let backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)
    }

    struct FeedBasicCell {
        static let textAttributes: [String: NSObject] = [
            NSFontAttributeName: UIFont.feedMessageFont(),
        ]

        static let skillTextAttributes: [String: NSObject] = [
            NSFontAttributeName: UIFont.feedSkillFont(),
        ]

        static let voiceTimeLengthTextAttributes: [String: NSObject] = [
            NSFontAttributeName: UIFont.feedVoiceTimeLengthFont(),
        ]

        static let bottomLabelsTextAttributes: [String: NSObject] = [
            NSFontAttributeName: UIFont.feedBottomLabelsFont(),
        ]
    }

    struct FeedBiggerImageCell {
        static let imageSize: CGSize = CGSize(width: 160, height: 160)
    }

    struct FeedNormalImagesCell {
        static let imageSize: CGSize = CGSize(width: 80, height: 80)
    }

    struct SearchedFeedNormalImagesCell {
        static let imageSize: CGSize = CGSize(width: 70, height: 70)
    }

    struct FeedView {
        static let textAttributes: [String: NSObject] = [
            NSFontAttributeName: UIFont.feedMessageFont(),
        ]
    }

    struct Conversation {
        static let hasUnreadMessagesPredicate = NSPredicate(format: "hasUnreadMessages = true")
    }
}

