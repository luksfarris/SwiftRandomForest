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

protocol Numeric:Hashable, Comparable {
    static func parse(text:String) -> Self
    static func fromInt(int:Int) -> Self
    func toDouble() -> Double
}
extension Float: Numeric {
    static func parse(text: String) -> Float {
        return Float(text) ?? 0.0
    }
    static func fromInt(int: Int) -> Float {
        return Float(int)
    }
    func toDouble() -> Double {
        return Double(self)
    }
}
extension Double: Numeric {
    static func parse(text: String) -> Double {
        return Double(text) ?? 0.0
    }
    static func fromInt(int: Int) -> Double {
        return Double(int)
    }
    func toDouble() -> Double {
        return self
    }
}
extension Int: Numeric {
    static func parse(text: String) -> Int {
        return Int(text) ?? 0
    }
    static func fromInt(int: Int) -> Int {
        return int
    }
    func toDouble() -> Double {
        return Double(self)
    }
}
extension UInt8: Numeric {
    static func parse(text: String) -> UInt8 {
        return UInt8(text) ?? 0
    }
    static func fromInt(int: Int) -> UInt8 {
        return UInt8(int)
    }
    func toDouble() -> Double {
        return Double(self)
    }
}
