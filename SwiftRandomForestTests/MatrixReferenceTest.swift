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

class MatrixReferenceTest: XCTestCase {
    
    override func setUp() {super.setUp()}
    override func tearDown() {super.tearDown()}
    
    func test() {
        
        let mat = MatrixTest.createDemoMatrix()
        
        let ref = MatrixReference<Int>.init(matrix: mat)
        ref.fill(3)
        let refCopy = MatrixReference<Int>.init(matrixReference: ref, count: ref.count)
        refCopy.fill(3)
        
        assert(ref.columns == 2)
        assert(refCopy.columns == 2)
        assert(ref.elementAt(0, 0) == 1)
        assert(refCopy.elementAt(0, 0) == 1)
        assert(ref.rowAtIndex(1)[0] == 2)
        assert(refCopy.rowAtIndex(2)[1] == 3)
        assert(ref.remove(1)==1)
        let popped = refCopy.remove(1)
        assert(popped==1)
        assert(ref.count == 2)
        assert(refCopy.count == 2)
        assert(ref.rowAtIndex(1)[0] == 3)
        assert(refCopy.rowAtIndex(1)[0] == 3)
        ref.append(index: 1)
        refCopy.append(index: 1)
        
    }
    
}
