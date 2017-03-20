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

import XCTest

class MatrixTest: XCTestCase {
    
    override func setUp() {super.setUp()}
    override func tearDown() {super.tearDown()}
    
    public static func createDemoMatrix() -> Matrix<Int> {
        let mat = Matrix<Int>.init(rows: 3, columns: 2)
        mat[0,0]=1
        mat[0,1]=1
        mat[1,0]=2
        mat[1,1]=2
        mat[2,0]=3
        mat[2,1]=3
        return mat
    }
    
    func test() {
        let mat = MatrixTest.createDemoMatrix()
        assert(mat[0,0]==1)
        assert(mat[2,1]==3)
        assert(mat.rowAtIndex(1)[0]==2)
        assert(mat.rowAtIndex(2)[1]==3)
        
        assert([0,0,0].freq(value:0)==3)
        
    }
}
