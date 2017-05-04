//
//  Extensions.swift
//  FiveYears
//
//  Created by Jan B on 04.05.17.
//  Copyright © 2017 Jan Busse. All rights reserved.
//

import Foundation

func toRoman(number: Int) -> String {
    
    let romanValues = ["M", "CM", "D", "CD", "C", "XC", "L", "XL", "X", "IX", "V", "IV", "I"]
    let arabicValues = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1]
    
    var romanValue = ""
    var startingValue = number
    
    for (index, romanChar) in romanValues.enumerated() {
        let arabicValue = arabicValues[index]
        
        let div = startingValue / arabicValue
        
        if (div > 0)
        {
            for _ in 0..<div
            {
                //println("Should add \(romanChar) to string")
                romanValue += romanChar
            }
            
            startingValue -= arabicValue * div
        }
    }
    
    return romanValue
}
