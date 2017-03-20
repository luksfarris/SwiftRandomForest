# SwiftRandomForest
Swift 3 implementation of Random Forest algorithm

<img src="/img/clubs.jpg" width="127" height="127">

## TODO List

- [x] Generic type algorithm
- [x] Cross Validation Algorithm
- [x] Add weights to features
- [x] Parallel tree building
- [ ] Faster matrix data structure
- [ ] Extend code to work with any comparable object
- [ ] Automatically detect outputs
- [ ] Better Unit tests
- [ ] Add Documentation
- [ ] Build for MacOS, iOS, tvOs, watchOS ...
- [ ] CocoaPods and Carthage

## Parameters

| Name                 | Type                | Description                                | Default   |
   | -------------------- | ------------------- | ---------------------------------------- | -------- |
   | maxDepth  | `Int` (1,∞)         | Maximum depth between root and leaf nodes. Increasing this makes the algorithm slower and more precise | `10`     |
   | minSize | `Int` (1,∞)         | Minimum `dataset` instances stored in each node. Increasing this makes the algorithm faster but less precise | `50`     |
   | sampleSize  | `Double`(0,1)       | Percentage of the `dataset` to be sampled in each tree. Helps create different trees | `0.1`    |
   | treesCount    | `Int`(1,∞)          | Number of build trees            | `10`     |
   | seed              | `String`            | Random generator seeds | `"Seed"` |
   | splitType        | `[All, Sqrt, Log2]` | Number of features used in each split. Helps create different splits | `Sqrt`   |
   | balancedTrees        | `Bool` | Set true if you want the trees to be built balanced | `false`   |
   | weighs        | `[Int]` | Set this if you want the features to be weighed. The values are used proportionally  | `[]`   |

## Usage

````Swift
let rd = CSVReader<Double>.init(encoding: .utf8, hasHeader: true)
self.matrix = rd.parseFileWith(name:"database")
        
let rf = RandomForest<Double>.init(maxDepth:30, minSize:10, sampleSize:0.5, balancedTrees:true, weighs:[1,1], outputClasses: self.matrix!.outputClasses!)
        
let cv = CrossValidation<Double,RandomForest<Double>>.init(algorithm: rf, folds: 5)
cv.evaluateAlgorithm(dataset: self.matrix!)

````
