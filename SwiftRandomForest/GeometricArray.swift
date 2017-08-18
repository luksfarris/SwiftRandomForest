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


class GeometricArray:Equatable {
    
    public private(set) var dimensions:Int
    public private(set) var values:[Double] = []
    
    init(_ dimensions:Int) {
        self.dimensions = dimensions
        for _ in 0..<dimensions {
            values.append(0)
        }
    }
    
    public func setElement(at index:Int, with value:Double) {
        guard index < dimensions else {
            fatalError("Invalid index")
        }
        values[index] = value
    }
    
    public func euclideanDistance(to array:GeometricArray) -> Double {
        guard self.dimensions == array.dimensions else {
            fatalError("Arrays have different number of dimensions")
        }
        var sum:Double = 0
        for i in 0..<dimensions {
            sum += (values[i] - array.values[i]) * (values[i] - array.values[i])
        }
        return sqrt(sum)
    }
    
    static func == (lhs: GeometricArray, rhs: GeometricArray) -> Bool {
        var equal = true
        guard lhs.dimensions == rhs.dimensions else {
            return false
        }
        for i in 0..<lhs.dimensions {
            if lhs.values[i] != rhs.values[i] {
                equal = false
                break
            }
        }
        return equal
    }
}
