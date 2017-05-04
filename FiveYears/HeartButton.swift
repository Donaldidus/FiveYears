//
//  HeartView.swift
//  FiveYears
//
//  Created by Jan B on 23.04.17.
//  Copyright © 2017 Jan Busse. All rights reserved.
//

import UIKit

class HeartButton: UIButton {
    
    override func draw(_ rect: CGRect) {
        
        let width = min(self.bounds.width, self.bounds.height)
        
        let heartRect = CGRect(origin: self.bounds.origin, size: CGSize(width: width, height: width))
        
        let heart = UIBezierPath(heartIn: heartRect)
        
        HEART_COLOR.setFill()
        heart.fill()
        
        HEART_COLOR.setStroke()
        
        heart.stroke()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        isOpaque = false
    }
    

}
