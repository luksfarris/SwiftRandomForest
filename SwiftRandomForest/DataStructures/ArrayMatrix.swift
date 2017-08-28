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

extension ArraySlice:ArrayProtocol {
    func element(at index: Int) -> Any {
        return self[self.startIndex + index]
    }
}

class ArrayMatrix<T:Numeric>: GenericMatrix<T> {
    
    private var grid:[T]
    typealias ArrayType = UnsafeMutablePointer<T>
    
    required init(rows: Int, columns: Int) {
        let elements = columns * rows
        grid = Array<T>.init(repeating: T.fromInt(int: 0), count: elements)
        super.init(rows: rows, columns: columns)
    }
    
    override subscript(row: Int, column: Int) -> T {
        get {
            guard row < rows && column < columns else {
                fatalError("Invalid row or column")
            }
            return grid[(row * columns) + column]
        }
        set {
            guard row < rows && column < columns else {
                fatalError("Invalid row or column")
            }
            grid[(row * columns) + column] = newValue
        }
    }
    
    override func append(_ matrix: GenericMatrix<T>) {
        if let mat = matrix as? ArrayMatrix {
            guard columns == mat.columns else {
                fatalError("Invalid matrix")
            }
            self.rows += mat.rows
            self.grid.append(contentsOf: mat.grid)
        }
    }
    
    override func append(_ row: ArrayProtocol, at index: Int) {
        
        if let slice = row as? ArraySlice<T> {
            guard index <= rows else {
                fatalError("Invalid index")
            }
            self.rows += 1
            self.grid.insert(contentsOf: slice, at: index*columns)
        }
    }
    
    override func removeRows(in range:Range<Int>) {
        guard range.lowerBound+range.count <= rows else {
            fatalError("Invalid range")
        }
        let startingIndex = range.lowerBound * self.columns
        let endingIndex = range.upperBound * self.columns
        self.grid.removeSubrange(startingIndex..<endingIndex)
        rows -= range.count
    }
    
    
    override func row(at index: Int) -> ArrayProtocol {
        let position = index*columns
        return grid[position..<(position+columns)]
    }

}
