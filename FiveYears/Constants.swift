//
//  Constants.swift
//  FiveYears
//
//  Created by Jan B on 21.04.17.
//  Copyright © 2017 Jan Busse. All rights reserved.
//

import UIKit

// MARK: UI Colors sizes etc

let BACKGROUND_COLOR = UIColor(hexString: "#F06292") // #87475d

let IMAGE_BACKGROUND_COLOR = UIColor(hexString: "#f97ca7")

let NAVIGATION_BAR_COLOR = UIColor(hexString: "E91E63")

let HEART_COLOR = UIColor(hexString: "#cc0000")

let HEART_BEAT_RESIZE: CGFloat = 0.9

let TEXT_FONT = UIFont(name: "Baskerville", size: 21)

let TEXT_FONT_NAME = "Baskerville"

let TEXT_COLOR = UIColor.white // UIColor(hexString: "#333333")

let TEXTVIEW_CONTAINER_INSETS = UIEdgeInsets(top: 15, left: 8, bottom: 10, right: 8)

let RELOAD_BUTTON_ANIMATION_COLOR = UIColor.white

// MARK: Storyboard Identifiers

struct StoryboardIdentifier {
    static let memorycell = "memoryCell"
    static let allmemoriessegue = "allmemoriessegue"
    
    static let UnwindCancelSegue = "UnwindCancel"
    static let UnwindMemorySegue = "UnwindMemory"
}

// extension that will allow to create a UIColor from a hexString code
extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
