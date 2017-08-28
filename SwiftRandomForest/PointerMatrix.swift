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

extension UnsafeMutablePointer:ArrayProtocol {
    func element(at index: Int) -> Any {return self[index]}
}

class PointerMatrix<T:Numeric>: GenericMatrix<T> {
    
    private var grid:UnsafeMutableRawPointer
    
    typealias ArrayType = UnsafeMutablePointer<T>
    
    required init(rows: Int, columns: Int) {
        grid = UnsafeMutableRawPointer.allocate(bytes: columns * rows * MemoryLayout<T>.size, alignedTo: 0)
        grid.initializeMemory(as: T.self, to: T.fromInt(int: 0))
        super.init(rows: rows, columns: columns)
    }
    
    deinit {
        grid.deallocate(bytes: columns * rows * MemoryLayout<T>.size, alignedTo: 0)
    }
    
    override subscript(row: Int, column: Int) -> T {
        get {
            guard row < rows && column < columns else {
                fatalError("Invalid row or column")
            }
            return grid.assumingMemoryBound(to: T.self)[(row * columns) + column]
        }
        set {
            guard row < rows && column < columns else {
                fatalError("Invalid row or column")
            }
            grid.assumingMemoryBound(to: T.self)[(row * columns) + column] = newValue
        }
    }
    
    override func append(_ matrix: GenericMatrix<T>) {
        if let mat = matrix as? PointerMatrix {
            guard columns == mat.columns else {
                fatalError("Invalid matrix")
            }
            let index = self.rows
            self.rows += mat.rows
            // first we allocate more space
            grid = realloc(grid, columns * rows * MemoryLayout<T>.size)
            // second we copy the memory
            if let pointer = row(at: index) as? UnsafeMutablePointer<T> {
                memcpy(pointer, mat.grid, matrix.rows*matrix.columns)
            }
        }
    }
    
    override func append(_ row: ArrayProtocol, at index: Int) {
        if let pointer = row as? UnsafeMutablePointer<T> {
            guard index <= rows else {
                fatalError("Invalid index")
            }
            self.rows += 1
            // first we need to allocate more data
            grid = realloc(grid, columns * rows * MemoryLayout<T>.size)
            // second we need to move the memory after the index
            var i:Int = rows - 1
            while i > index {
                for j in 0..<columns {
                    self[i,j] = self[i-1,j]
                }
                i -= 1
            }
            for j in 0..<columns {
                self[index,j] = pointer[j]
            }
        }
    }
    
    override func removeRows(in range:Range<Int>) {
        guard range.lowerBound+range.count <= rows else {
            fatalError("Invalid range")
        }
        let startingIndex = range.lowerBound * self.columns
        let endingIndex = rows*columns
        let shiftSize = range.count * self.columns
        for i in startingIndex..<(endingIndex) {
            if (i+shiftSize < rows*columns) {
                grid.assumingMemoryBound(to: T.self)[i] = grid.assumingMemoryBound(to: T.self)[i+shiftSize]
            }
        }
        rows -= range.count
        grid = realloc(grid, rows * MemoryLayout<T>.size)
    }
    
    override func row(at index: Int) -> ArrayProtocol {
        return grid.assumingMemoryBound(to: T.self)+index*self.columns
    }
    
}
