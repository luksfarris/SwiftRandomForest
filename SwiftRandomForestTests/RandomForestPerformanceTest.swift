//
//  RandomForestPerformanceTest.swift
//  SwiftRandomForest
//
//  Created by Lucas Farris on 02/06/2017.
//  Copyright © 2017 Lucas Farris. All rights reserved.
//

import XCTest

class RandomForestPerformanceTest: XCTestCase {
    
    func testExample() {
        
        let rows = 1000
        let cols = 5
        
        let mat = Matrix<Int>.init(rows: rows, columns: cols)
        for i in 0..<rows {
            for _ in 0..<cols {
                mat.append( ((i<rows/2) ? 0 : 1) )
            }
        }
        
        let dataset = MatrixReference<Int>.init(matrix: mat)
        dataset.fill(200)
        
        let rf = RandomForest.init(maxDepth: 100, minSize:20,sampleSize:0.2, treesCount:12, seed:"Magic", weighs:[1,2], outputClasses: [0,1])
        let train = rf.subsample(dataset: dataset, sampleRatio: 0.8)
        let test = rf.subsample(dataset: dataset, sampleRatio: 0.2)
        
        measure {
            rf.runClassifier(trainDataset: train, testDataset: test) { (outputs:Array<Int>) in
                // Classifier finished running
            }
        }
    }
    
}
