//
//  ClassifierAlgorithm.swift
//  SwiftRandomForest
//
//  Created by Lucas Farris on 16/08/2017.
//  Copyright © 2017 Lucas Farris. All rights reserved.
//

import Foundation


protocol ClassifierAlgorithm {
    associatedtype NumericType:Numeric
    func runClassifier(trainDataset:MatrixReference<NumericType>, testDataset:MatrixReference<NumericType>, completion: @escaping (Array<NumericType>)->())
    func trainClassifier(trainDataset:MatrixReference<NumericType>, completion: @escaping ()->())
    func classify(testDataset: MatrixReference<NumericType>) -> Array<NumericType>
}
