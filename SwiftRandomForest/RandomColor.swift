//
//  RandomColor.swift
//  SwiftRandomForest
//
//  Created by Lucas Farris on 16/08/2017.
//  Copyright © 2017 Lucas Farris. All rights reserved.
//

import Foundation
import UIKit
import GameKit


extension UIColor {
    
    public static func random(_ seed:String) -> UIColor {
        let source = GKARC4RandomSource(seed: seed.data(using: .utf8)!)
        let red:Float = Float(source.nextInt(upperBound:256))/255.0
        let green:Float = Float(source.nextInt(upperBound:256))/255.0
        let blue:Float = Float(source.nextInt(upperBound:256))/255.0
        return UIColor(colorLiteralRed: red, green: green, blue: blue, alpha: 1.0)
    }
}
