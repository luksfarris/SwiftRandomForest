//MIT License
//
//Copyright (c) 2017 Lucas Farris
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.

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
