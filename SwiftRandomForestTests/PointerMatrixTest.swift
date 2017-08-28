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

class PointerMatrixTest: XCTestCase {
    
    func createDemoMatrix() -> GenericMatrix<UInt8> {
        return PointerMatrix<UInt8>.createDemoMatrix() 
    }
    
    
    func testMatrixAppendRow() {
        let mat1 = self.createDemoMatrix()
        let mat2 = self.createDemoMatrix()
        
        let row = mat2.row(at: 1)
        mat1.append(row, at: 1)
        assert(mat1[1,0]==1)
        assert(mat1[2,1]==1)
        assert(mat1[1,1]==1)
        assert(mat1[2,1]==1)
    }
    
    func testMatrixAppendRemove() {
        let mat1 = self.createDemoMatrix()
        let mat2 = self.createDemoMatrix()
        mat1.append(mat2)
        mat2.removeRows(in: 5..<6)
        assert(mat1[11,1]==5)
        assert(mat2[3,1]==3)
        mat1.removeRows(in: 4..<8)
        assert(mat1[7,1]==5)
    }
    
    func testMatrixAppend() {
        let mat1 = self.createDemoMatrix()
        let mat2 = self.createDemoMatrix()
        mat1.append(mat2)
        assert(mat1[6,0]==0)
        assert(mat1[11,1]==5)
    }
    
    func testMatrixRemove() {
        let mat = self.createDemoMatrix()
        mat.removeRows(in: 5..<6)
        assert(mat[0,0]==0)
        assert(mat[0,1]==0)
        assert(mat[3,1]==3)
        mat.removeRows(in: 0..<2)
        assert(mat[0,0]==2)
        assert(mat[0,1]==2)
        assert(mat[1,1]==3)
        mat.removeRows(in: 1..<2)
        assert(mat[0,0]==2)
        assert(mat[0,1]==2)
        assert(mat[1,1]==4)
    }
    
    func testMatrixInit() {
        let mat = self.createDemoMatrix()
        // test subscripts working
        assert(mat[0,0]==0)
        assert(mat[2,1]==2)
        // test row at index working
        assert(mat.row(at: 1).element(at: 0) as! UInt8 == 1)
        assert(mat.row(at: 2).element(at: 1) as! UInt8 == 2)
        // test frequency working
        assert([0,0,0].freq(value:0)==3)
    }
}
