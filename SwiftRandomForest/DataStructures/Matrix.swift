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

class Matrix<T:Numeric> {
    
    private var grid:Array<T> = []
    public private(set) var rows: Int, columns: Int
    var outputClasses:[T]?
    
    init(rows: Int, columns: Int) {
        self.rows = rows
        self.columns = columns
    }
    
    subscript(row: Int, column: Int) -> T {
        get {
            return grid[(row * columns) + column]
        }
        set {
            grid[(row * columns) + column] = newValue
        }
    }
    
    public func append(_ element:T) {
        self.grid.append(element)
    }
    
    public func rowAtIndex(_ index: Int) -> ArraySlice<T> {
        return grid[index*self.columns..<(index+1)*self.columns]
    }
}

extension Sequence where Self.Iterator.Element: Hashable {
    typealias Element = Self.Iterator.Element
    func freq(value:Element) -> Int {
        return reduce(0) { (accu: Int, element) in
            var accumulator = accu
            if (element == value) {
                 accumulator += 1
            }
            return accumulator
        }
    }
}

