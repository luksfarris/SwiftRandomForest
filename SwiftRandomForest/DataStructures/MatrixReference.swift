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

class MatrixReference<T:Numeric> {
    
    public private(set) var matrix:Matrix<T>
    public private(set) var rows:Array<Int> = []
    public private(set) var count:Int = 0
    public private(set) var maxCount:Int = 0
    public private(set) var columns:Int = 0
    
    init (matrix:Matrix<T>) {
        self.matrix = matrix
        self.maxCount = matrix.rows
        self.columns = matrix.columns
    }
    
    init (matrixReference:MatrixReference<T>, count:Int) {
        self.matrix = matrixReference.matrix
        self.maxCount = count
        self.columns = matrixReference.columns
    }
    
    public func elementAt(_ row:Int, _ column:Int) -> T {
        let realRow = self.rows[row]
        return self.matrix[realRow,column]
    }
    
    public func rowAtIndex(_ index: Int) -> ArraySlice<T> {
        let realIndex = self.rows[index]
        return self.matrix.rowAtIndex(realIndex)
    }
    
    public func remove(_ index:Int) -> Int {
        let poppedIndex:Int = self.rows.remove(at: index)
        self.count -= 1
        self.maxCount -= 1
        return poppedIndex
    }
    
    public func append(index:Int) {
        self.count += 1
        self.rows.append(index)
    }
    
    public func append(otherMatrix:MatrixReference<T>) {
        self.count += otherMatrix.count
        for i in 0..<otherMatrix.count {
            let value = otherMatrix.rows[i]
            self.rows.append(value)
        }
    }
    
    public func fill(_ count:Int) {
        self.count = count
        for i in 0..<self.count {
            self.rows.append(i)
        }
    }
    
    func makeIterator() -> MatrixReferenceIterator<T> {
        return MatrixReferenceIterator<T>(rows: self.rows, count:self.count, matrix:self.matrix)
    }
}

struct MatrixReferenceIterator<T:Numeric> : IteratorProtocol {
    private var rows:Array<Int>
    private var matrix:Matrix<T>
    private var count:Int
    private var index = 0
    init(rows:Array<Int>, count:Int, matrix:Matrix<T>) {
        self.rows = rows
        self.count = count
        self.matrix = matrix
    }
    
    mutating func next() -> ArraySlice<T>? {
        if self.index < self.count {
            let realIndex = self.rows[self.index]
            self.index += 1
            return self.matrix.rowAtIndex(realIndex)
        } else {
            return nil
        }
    }
}

extension MatrixReference {
    var outputs: Array<T> {
        var outputsArray:Array<T> = []
        for i in 0..<self.count {
            let row = self.rows[i]
            outputsArray.append(self.matrix[row,self.columns - 1])
        }
        return outputsArray
    }
}
