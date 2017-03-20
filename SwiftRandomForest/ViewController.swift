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

import UIKit

class ViewController: UIViewController {

    var matrix:Matrix<Double>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rd = CSVReader<Double>.init(encoding: .utf8, hasHeader: true)
        self.matrix = rd.parseFileWith(name:"database")
        
        let rf = RandomForest<Double>.init(maxDepth:30, minSize:10, sampleSize:0.5, balancedTrees:true, weighs:[1,1], outputClasses: self.matrix!.outputClasses!)
        
        let cv = CrossValidation<Double,RandomForest<Double>>.init(algorithm: rf, folds: 5)
        cv.evaluateAlgorithm(dataset: self.matrix!)
    }
    
}

