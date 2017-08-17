//
//  RandomForestPerformanceTest.swift
//  SwiftRandomForest
//
//  Created by Lucas Farris on 02/06/2017.
//  Copyright © 2017 Lucas Farris. All rights reserved.
//

import XCTest

class RandomForestPerformanceTest: XCTestCase {
    
    func testPerformance() {
        
        measure {
            let reader = CSVReader<Int>.init(encoding: String.Encoding.utf8, hasHeader: true)
            let matrix = reader.parseFileWith(name: "mock")
            let dataset = MatrixReference<Int>.init(matrix: matrix!)
            dataset.fill(100)
            
            let rf = RandomForest.init(maxDepth: 100, minSize:20,sampleSize:0.2, treesCount:12, seed:"Magic", weighs:[1,2], outputClasses: [0,1])
            let train = rf.subsample(dataset: dataset, sampleRatio: 0.8)
            let test = rf.subsample(dataset: dataset, sampleRatio: 0.2)
            let expect = self.expectation(description: "Expect it to finish running")
            rf.runClassifier(trainDataset: train, testDataset: test) { (outputs:Array<Int>) in
                // Classifier finished running
                expect.fulfill()
            }
            self.wait(for: [expect], timeout: 1000)
        }
    }
    
}
