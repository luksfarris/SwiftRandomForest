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
import UIKit
import GameKit

class KMeans<T:Numeric>: ClassifierAlgorithm<T> {
    
    public private(set) var centroidCount:Int
    public private(set) var maxIterations:Int
    public private(set) var convergenceDelta:Double
    
    private var randomSource:GKARC4RandomSource
    private var centroids:[GeometricArray] = []
    private var generators:[GKRandomDistribution] = []
    
    init(centroidCount:Int = 4, maxIterations:Int = 500, convergenceDelta:Double = 2.0, seed:String = "Seed") {
        self.centroidCount = centroidCount
        self.maxIterations = maxIterations
        self.convergenceDelta = convergenceDelta
        self.randomSource = GKARC4RandomSource(seed: seed.data(using: .utf8)!)
    }
    
    private func initializeRandomGenerators(_ dataset:MatrixReference<T>) {
        // we create one generator for each row
        for i in 0..<dataset.columns-1 {
            // find the max and min values
            var min:Double = dataset.elementAt(0, i).toDouble()
            var max:Double = dataset.elementAt(0, i).toDouble()
            for row in dataset.rows {
                let element = dataset.elementAt(row, i).toDouble()
                if element > max {
                    max = element.toDouble()
                }
                if element < min {
                    min = element.toDouble()
                }
            }
            generators.append(GKRandomDistribution(randomSource: randomSource, lowestValue: Int(min), highestValue: Int(max)))
        }
    }
    
    private func initializeCentroids(_ dataset:MatrixReference<T>) {
        initializeRandomGenerators(dataset)
        centroids = []
        // randomly initialize one centroid for each class
        for _ in 0..<centroidCount {
            centroids.append(GeometricArray(dataset.columns-1))
        }
        for i in 0..<dataset.columns-1 {
            for j in 0..<centroidCount {
                centroids[j].setElement(at: i, with: Double(generators[i].nextInt()))
            }
        }
    }
    
    private func shouldStop(_ iteration:Int, _ oldCentroids:[GeometricArray]) -> Bool {
        if oldCentroids.count != centroids.count {
            return false
        } else if iteration > maxIterations {
            return true
        }
        var converged = true
        for i in 0..<centroidCount {
            if oldCentroids[i].euclideanDistance(to: centroids[i]) > convergenceDelta {
                converged = false
                break
            }
        }
        return converged
    }
    
    private func predict(_ dataset: MatrixReference<T>) -> [GeometricArray] {
        var classes:[GeometricArray] = []
        for row in dataset.rows {
            // get each row
            let rowArray = GeometricArray(dataset.columns-1)
            for i in 0..<dataset.columns-1 {
                rowArray.setElement(at: i, with: dataset.elementAt(row, i).toDouble())
            }
            // find the closes centroid
            var closestCentroid = centroids[0]
            for centroid in centroids {
                if rowArray.euclideanDistance(to: centroid) < rowArray.euclideanDistance(to: closestCentroid) {
                    closestCentroid = centroid
                }
            }
            classes.append(closestCentroid)
        }
        return classes
    }
    
    private func recalculateCentroids(_ dataset: MatrixReference<T> , _ predictions:[GeometricArray]) -> [GeometricArray] {
        var newCentroids:[GeometricArray] = []
        // we need to recalculate each centroid
        for centroid in centroids {
            // each one is the mean of the elements that are assigned to it
            let assignedElements = predictions.filter({ (element) -> Bool in
                element == centroid
            })
            let indexes = assignedElements.map({ (element) -> Int in
                return predictions.index(of: element) ?? -1
            })
            let newCentroid = GeometricArray.init(centroid.dimensions)
            for i in 0..<dataset.columns-1 {
                // if there is no index, we need to randomly reinitialize the centroid
                if indexes.isEmpty {
                    newCentroid.setElement(at: i, with: Double(generators[i].nextInt()))
                } else {
                    let sum = indexes.reduce(0, { (accumulator:Double, element) -> Double in
                        return accumulator + dataset.elementAt(element, i).toDouble()
                    })
                    newCentroid.setElement(at: i, with: sum/Double(indexes.count))
                }
            }
            newCentroids.append(newCentroid)
        }
        return newCentroids
    }
    
    private func kmeans(_ dataset: MatrixReference<T>) {
        initializeCentroids(dataset)
        var iterations = 0
        var oldCentroids:[GeometricArray] = []
        while !shouldStop(iterations, oldCentroids) {
            oldCentroids = centroids
            iterations += 1
            let predictions:[GeometricArray] = predict(dataset)
            centroids = recalculateCentroids(dataset, predictions)
        }
    }
    
    private func classesFromCentroids(_ dataset: MatrixReference<T>) -> [T] {
        var classes:[T] = []
        for prediction in predict(dataset) {
            if let index = centroids.index(of: prediction) {
                classes.append(T.fromInt(int: centroids.startIndex.distance(to: index)))
            } else {
                classes.append(T.fromInt(int: -1))
            }
        }
        return classes
    }
    
    override func classify(testDataset: MatrixReference<T>) -> [T] {
        kmeans(testDataset)
        return classesFromCentroids(testDataset)
    }
    
    override func trainClassifier(trainDataset: MatrixReference<T>, completion: @escaping () -> ()) {
        fatalError("The KMeans algorithm is unsupervised")
    }
    
    override func runClassifier(trainDataset: MatrixReference<T>, testDataset: MatrixReference<T>, completion: @escaping (Array<T>) -> ()) {
        completion(classify(testDataset: trainDataset))
    }
    
}
