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


protocol ArrayProtocol {
    func element(at index:Int) -> Any
}

class GenericArray:ArrayProtocol {
    func element(at index: Int) -> Any {fatalError()}
    func set(element: Any, at index: Int) {fatalError()}
}

protocol MatrixProtocol {
    
    associatedtype NumericType:Numeric
    
    var rows:Int {get set}
    var columns:Int {get set}
    
    subscript(row: Int, column: Int) -> NumericType { get set }
    func row(at index: Int) -> ArrayProtocol
    
    func append(_ matrix:Self)
    func append(_ row:ArrayProtocol, at index:Int)
    func removeRows(in range:Range<Int>)
}



class GenericMatrix<T:Numeric>:MatrixProtocol, CustomStringConvertible {
    
    typealias ArrayType = GenericArray
    typealias NumericType = T
    
    var outputClasses:[T]?
    
    var rows:Int, columns:Int
    
    required init(rows: Int, columns: Int) {
        self.rows = rows
        self.columns = columns
    }
    
    subscript(row: Int, column: Int) -> NumericType {
        get {
            fatalError("Subclass must override")
        }
        set {
            fatalError("Subclass must override")
        }
    }
    
    func row(at index: Int) -> ArrayProtocol {
        fatalError("Subclass must override")
    }
    
    func append(_ matrix:GenericMatrix<T>) {
        fatalError("Subclass must override")
    }
    
    func append(_ row:ArrayProtocol, at index:Int) {
        fatalError("Subclass must override")
    }
    
    func removeRows(in range:Range<Int>) {
        fatalError("Subclass must override")
    }
    
    var description: String {
        var text = ""
        for row in 0..<rows {
            text += "["
            for col in 0..<columns {
                text += "\(self[row,col].toDouble())" + ((col == columns - 1) ? "" : ", ")
            }
            text += "]\n"
        }
        return text
    }
    
    static func createDemoMatrix() -> Self {
        let mat = self.init(rows: 6, columns: 2)
        mat[0,0]=T.fromInt(int: 0)
        mat[0,1]=T.fromInt(int: 0)
        mat[1,0]=T.fromInt(int: 1)
        mat[1,1]=T.fromInt(int: 1)
        mat[2,0]=T.fromInt(int: 2)
        mat[2,1]=T.fromInt(int: 2)
        mat[3,0]=T.fromInt(int: 3)
        mat[3,1]=T.fromInt(int: 3)
        mat[4,0]=T.fromInt(int: 4)
        mat[4,1]=T.fromInt(int: 4)
        mat[5,0]=T.fromInt(int: 5)
        mat[5,1]=T.fromInt(int: 5)
        return mat
    }
}
