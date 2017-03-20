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

class RandomForestTest: XCTestCase {
    
    
    var mat = RandomForestTest.createDataset()
    
    static func createDataset() -> Matrix<Int> {
        let mat = Matrix<Int>.init(rows: 200, columns: 4)
        for i in 0..<100 {
            for j in 0..<4 {
                mat[i,j]=0
                mat[i+100,j]=1
            }
        }
        return mat
    }
    
    func test() {
        
        
        let dataset = MatrixReference<Int>.init(matrix: mat)
        dataset.fill(200)
        
        let rf = RandomForest.init(outputClasses: [0,1])
        let train = rf.subsample(dataset: dataset, sampleRatio: 0.8)
        let test = rf.subsample(dataset: dataset, sampleRatio: 0.2)
        
        assert(train.count == 160)
        assert(test.count == 40)
        
        rf.runClassifier(trainDataset: train, testDataset: test) { (outputs:Array<Int>) in
            
            for i in 0..<40 {
                assert(outputs[i]==test.outputs[i])
            }
            
        }
        
    }
    
}
