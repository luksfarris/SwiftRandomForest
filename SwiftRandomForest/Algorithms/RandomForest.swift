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
import GameKit

enum FeatureSplitType {
    case All
    case Sqrt
    case Log2
}

class RandomForest<T:Numeric>: ClassifierAlgorithm {
    
    typealias NumericType = T

    public private(set) var maxDepth:Int
    public private(set) var minSize:Int
    public private(set) var sampleSize:Double
    public private(set) var treesCount:Int
    public private(set) var balancedTrees:Bool
    public private(set) var weighs:Array<Int>
    private var totalWeight:Int
    public private(set) var splitType:FeatureSplitType
    private var randomSource:GKARC4RandomSource
    
    public private(set) var trees:ThreadSafeArray<TreeNode<T>> = ThreadSafeArray<TreeNode<T>>.init()
    
    private private(set) var outputClasses:[T]
    private let pendingOperations = PendingOperations(queueName: "treeQueue", concurrentOperations: 4)
    
    init(maxDepth:Int = 10, minSize:Int = 50, sampleSize:Double = 0.1, treesCount:Int = 10, seed:String = "Seed", splitType:FeatureSplitType = .Sqrt, balancedTrees:Bool = false, weighs:Array<Int> = [], outputClasses:[T]) {
        
        self.randomSource = GKARC4RandomSource(seed: seed.data(using: .utf8)!)
        self.maxDepth = maxDepth
        self.minSize = minSize
        self.sampleSize = sampleSize
        self.treesCount = treesCount
        self.splitType = splitType
        self.balancedTrees = balancedTrees
        self.outputClasses = outputClasses
        if weighs.count == outputClasses.count {
            self.weighs = weighs
        } else {
            self.weighs = Array(repeating: 1, count: outputClasses.count)
        }
        self.totalWeight = self.weighs.reduce(0, +)
    }
    
    
    func runClassifier(trainDataset:MatrixReference<T>, testDataset:MatrixReference<T>, completion: @escaping (Array<NumericType>)->()) {
        randomForestTrain(trainDataset) {
            let predictions = self.randomForestTest(testDataset)
            self.trees.clear()
            completion(predictions)
        }
    }
    
    func trainClassifier(trainDataset: MatrixReference<T>, completion: @escaping () -> ()) {
        randomForestTrain(trainDataset, completion: completion)
    }
    
    func classify(testDataset: MatrixReference<T>) -> Array<NumericType> {
        let predictions = self.randomForestTest(testDataset)
        self.trees.clear()
        return predictions
    }
    
    public func subsample(dataset:MatrixReference<T>, sampleRatio:Double) -> MatrixReference<T> {
        
        if (!self.balancedTrees) {
            let sampleCount:Int = Int(round(Double(dataset.count) * sampleRatio))
            let sample = MatrixReference<T>.init(matrixReference: dataset, count:sampleCount)
            while sample.count < sampleCount {
                let index = self.randomSource.nextInt(upperBound:dataset.count)
                sample.append(index: index)
            }
            return sample
            
        } else {
            
            var smallestClassCount:Int = dataset.count
            for classOutput in self.outputClasses {
                let outputs = dataset.outputs
                let classCount = outputs.freq(value: classOutput)
                if classCount < smallestClassCount {
                    smallestClassCount = classCount
                }
            }
            
            let classSampleCount:Int = Int(Double(smallestClassCount) * sampleRatio)
            let sample = MatrixReference<T>.init(matrixReference: dataset, count:classSampleCount * self.outputClasses.count)
            
            for classOutput in self.outputClasses {
                var classCount = 0
                while classCount < classSampleCount {
                    let index = self.randomSource.nextInt(upperBound:dataset.count)
                    
                    let row = dataset.rowAtIndex(index)
                    
                    if row[row.startIndex + dataset.columns-1] == classOutput {
                        sample.append(index: index)
                        classCount += 1
                    }
                }
            }
            return sample
        }
    }
    
    public func buildTree(train:MatrixReference<T>, maxDepth:Int, minSize:Int, featuresCount:Int) -> TreeNode<T> {
        
        let root:TreeNode<T> = getSplit(dataset: train, featuresCount:featuresCount)
        split(node: root,maxDepth:maxDepth,minSize: minSize,featuresCount:featuresCount,depth:1)
        return root
    }
    
    private func randomForestTest(_ test:MatrixReference<T>) -> Array<T> {
        var predictions:Array<T> = []
        for i in 0..<test.count {
            predictions.append(baggingPredict(test.rowAtIndex(i)))
        }
        return predictions
    }
    
    
    private func randomForestTrain (_ train:MatrixReference<T>, completion: @escaping ()->()) {
        for _ in 0..<self.treesCount {
            let treeBuilder = TreeBuilder<T>.init(randomForest: self, trainDataset: train)
            treeBuilder.completionBlock = {
                if (self.trees.count == self.treesCount) {
                    completion()
                }
            }
            self.pendingOperations.buildQueue.addOperation(treeBuilder)
        }
    }
    
    private func baggingPredict(_ row:ArraySlice<T>) -> T {
        
        var predictions:Array<T> = []
        for i in 0..<self.trees.count {
            if let validPrediction = predict(node:self.trees[i], row: row) {
                predictions.append(validPrediction)
            }
        }
        
        var bestClass:T = T.parse(text:"\(0)")
        var bestClassCount:Int = -1
        for i in 0..<self.outputClasses.count {
            let outputClass = self.outputClasses[i]
            let weight = self.weighs[i]
            if predictions.freq(value: outputClass) * weight > bestClassCount {
                bestClass = outputClass
                bestClassCount = predictions.freq(value: outputClass)
            }
        }
        return bestClass
    }
    
    private func predict(node:TreeNode<T>, row:ArraySlice<T>) -> T? {
        if let bestIndex = node.bestIndex, let bestValue = node.bestValue, let leftNode = node.left, let rightNode = node.right {
            if row[row.startIndex+bestIndex] < bestValue {
                if let terminalValue = leftNode.terminalValue {
                    return terminalValue
                } else {
                    return predict(node: leftNode, row: row)
                }
            } else {
                if let terminalValue = rightNode.terminalValue {
                    return terminalValue
                } else {
                    return predict(node: rightNode, row: row)
                }
            }
        }
        return nil
    }
    
    private func toTerminalNode(group:MatrixReference<T>) -> TreeNode<T> {
        var maxClassCount = -1;
        var maxClass:T = T.parse(text: "\(-1)")
        for value in self.outputClasses {
            let freq = group.outputs.freq(value:value)
            if (freq > maxClassCount) {
                maxClassCount = freq
                maxClass = value
            }
        }
        return TreeNode<T>.init(terminalValue: maxClass)
    }

    private func split(node:TreeNode<T>, maxDepth:Int, minSize:Int, featuresCount:Int, depth:Int) {
        
        if let bestGroup = node.bestGroup {
            let leftReference:MatrixReference<T> = bestGroup.left
            let rightReference:MatrixReference<T> = bestGroup.right
                    
            if (leftReference.count == 0 || rightReference.count == 0) {
                let terminal = toTerminalNode(group:(leftReference.count == 0 ? rightReference : leftReference))
                node.left = terminal
                node.right = terminal
                return
            }
            if (depth > maxDepth) {
                node.left = toTerminalNode(group: leftReference)
                node.right = toTerminalNode(group: rightReference)
                return
            }
            if (leftReference.count <= minSize) {
                node.left = toTerminalNode(group: leftReference)
            } else {
                let leftNode = getSplit(dataset: leftReference, featuresCount: featuresCount)
                node.left = leftNode
                split(node: leftNode, maxDepth: maxDepth, minSize: minSize, featuresCount: featuresCount, depth: depth+1)
            }
            if (rightReference.count <= minSize) {
                node.right = toTerminalNode(group: rightReference)
            } else {
                let rightNode = getSplit(dataset:rightReference, featuresCount:featuresCount)
                node.right = rightNode
                split(node: rightNode, maxDepth: maxDepth, minSize: minSize, featuresCount: featuresCount, depth: depth+1)
            }
        }
    }
    
    private func getSplit(dataset:MatrixReference<T>, featuresCount:Int) -> TreeNode<T> {
        var bestIndex:Int = 0
        var bestValue:T?
        var bestScore:Double = 999
        var bestGroup:Group<T>?
        var features:Array<Int> = []
        
        while features.count < featuresCount {
            let index:Int = self.randomSource.nextInt(upperBound: (dataset.columns-1))
            if !features.contains(index) {
                features.append(index)
            }
        }
        
        for index in features {
            for i in 0..<dataset.count {
                let row = dataset.rowAtIndex(i)
                let groups = self.testSplit(index:index, value:row[row.startIndex+index], dataset: dataset)
                let gini = self.giniIndex(groups: groups)
                if gini < bestScore {
                    bestIndex = index
                    bestValue = row[row.startIndex+index]
                    bestScore = gini
                    bestGroup = groups
                }
            }
        }
        return TreeNode.init(bestIndex: bestIndex, bestValue: bestValue, bestGroup: bestGroup)
    }
    
    private func giniIndex(groups:Group<T>) -> Double {
        var gini:Double = 0
        for i in 0..<self.outputClasses.count {
            let value = self.outputClasses[i]
            if (groups.left.count > 0) {
                let proportion:Double = Double(groups.left.outputs.freq(value:value))/Double(groups.left.count)
                let impurity = (proportion * (1.0 - proportion))
                gini += impurity * (Double(self.weighs[i])/Double(self.totalWeight))
            }
            if (groups.right.count > 0) {
                let proportion:Double = Double(groups.right.outputs.freq(value:value))/Double(groups.right.count)
                let impurity = (proportion * (1.0 - proportion))
                gini += impurity * (Double(self.weighs[i])/Double(self.totalWeight))
            }
            
        }
        
        
        return gini
    }
    
    private func testSplit(index:Int, value:T, dataset:MatrixReference<T>) -> Group<T> {
        
        var leftCount = 0
        var rightCount = 0
        
        for i in 0..<dataset.count {
            let feature = dataset.elementAt(i, index)
            if feature < value {
                leftCount += 1
            } else {
                rightCount += 1
            }
        }
        
        let left = MatrixReference.init(matrixReference: dataset, count:leftCount)
        let right = MatrixReference.init(matrixReference: dataset, count:rightCount)
        
        for i in 0..<dataset.count {
            let feature = dataset.elementAt(i, index)
            if feature < value {
                left.append(index: dataset.rows[i])
            } else {
                right.append(index: dataset.rows[i])
            }
        }
        
        return Group.init(left: left, right: right)
    }
}


class TreeBuilder<T:Numeric>:Operation {
    private var randomForest:RandomForest<T>
    private var trainDataset:MatrixReference<T>
    
    init(randomForest:RandomForest<T>, trainDataset:MatrixReference<T>) {
        self.randomForest = randomForest
        self.trainDataset = trainDataset
    }
    
    override func main() {
        let sample = randomForest.subsample(dataset: trainDataset, sampleRatio: randomForest.sampleSize)
        let splitSize = calculateSplitSize()
        let tree = randomForest.buildTree(train:sample, maxDepth: randomForest.maxDepth, minSize: randomForest.minSize, featuresCount:splitSize)
        randomForest.trees.append(tree)
        print("Tree number \(randomForest.trees.count) build")
    }
    
    private func calculateSplitSize() -> Int {
        var splitSize:Int = 0
        switch randomForest.splitType {
        case .All:
            splitSize = trainDataset.columns - 1
        case .Sqrt:
            splitSize = Int(sqrt(Double(trainDataset.columns - 1)))
        case .Log2:
            splitSize = Int(log2(Double(trainDataset.columns - 1)))
        }
        return splitSize
    }
}

