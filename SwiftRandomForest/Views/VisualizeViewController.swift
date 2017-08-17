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

enum VizualizationStep {
    case sampleData
    case trainClassifier
    case training
    case addRandomData
    case runClassifier
    case finished
}

enum SamplingDistribution {
    case Gaussian
}

class VisualizeViewController : UIViewController {
    
    @IBOutlet weak var plotView: UIView!
    @IBOutlet weak var actionButton: UIButton!
    
    public var supervised = true
    private var currentStep:VizualizationStep = .sampleData
    
    private let centroidsCount = 4
    private let radius = 50
    private let samplesForCentroid = 100
    
    private let testSize = 30
    
    private var trainData:MatrixReference<Int>?
    private var testData:MatrixReference<Int>?
    private var predictions:[Int]?
    private var classifier:RandomForest<Int>!
    var randomSource:GKARC4RandomSource!
    
    private let seed = "seed"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        trainData = MatrixReference<Int>(matrix: Matrix(rows: centroidsCount*samplesForCentroid, columns: 3))
        randomSource = GKARC4RandomSource(seed: seed.data(using: .utf8)!)
    }

    @IBAction func actionPressed(_ sender: Any) {
        nextStep()
    }
    
    private func nextStep() {
        if currentStep == .sampleData {
            sampleData()
            currentStep = .trainClassifier
        } else if currentStep == .trainClassifier {
            currentStep = .training
            trainClassifier()
        } else if currentStep == .addRandomData {
            addRandomData()
            currentStep = .runClassifier
        } else if currentStep == .runClassifier {
            runClassifier()
            currentStep = .finished
        }
        updateButton()
    }
    
    private func updateButton() {
        switch currentStep {
        case .sampleData:
            actionButton.setTitle("Sample Data", for: .normal)
            break
        case .addRandomData:
            actionButton.setTitle("Add Random Data", for: .normal)
            break
        case .training:
            actionButton.setTitle("Training ...", for: .normal)
            break
        case .runClassifier:
            actionButton.setTitle("Run Classifier", for: .normal)
            break
        case .trainClassifier:
            actionButton.setTitle("Train Classifier", for: .normal)
            break
        case .finished:
            actionButton.setTitle("Done", for: .normal)
            actionButton.isEnabled = false
            break
        }
    }
    
    private func addRandomData() {
        testData = MatrixReference<Int>(matrix: Matrix(rows: testSize, columns: 3))
        
        let randomDistributionX = GKRandomDistribution(randomSource: randomSource, lowestValue: radius, highestValue: Int(plotView.frame.width) - radius)
        let randomDistributionY = GKRandomDistribution(randomSource: randomSource, lowestValue: radius, highestValue: Int(plotView.frame.height) - radius)
        // sample random points in the plot
        for i in 0..<testSize {
            testData?.matrix.append(randomDistributionX.nextInt())
            testData?.matrix.append(randomDistributionY.nextInt())
            testData?.matrix.append(-1)
            testData?.append(index: i)
        }
        plot()
    }
    
    private func runClassifier() {
        if let dataset = testData {
            predictions = classifier.classify(testDataset: dataset)
            plot()
        }
    }
    
    private func trainClassifier() {
        
        classifier = RandomForest<Int>.init(outputClasses: Array(0..<centroidsCount))
        
        if let dataset = trainData {
            classifier.trainClassifier(trainDataset: dataset, completion: {
                DispatchQueue.global(qos: .background).async {
                    self.currentStep = .addRandomData
                    self.updateButton()
                }
            })
        }
    }
    
    private func sampleData() {
        var centroids:[CGPoint] = []
        // randomly elect centroids
        let randomDistributionX = GKRandomDistribution(randomSource: randomSource, lowestValue: radius, highestValue: Int(plotView.frame.width) - radius)
        let randomDistributionY = GKRandomDistribution(randomSource: randomSource, lowestValue: radius, highestValue: Int(plotView.frame.height) - radius)
        for _ in 0..<centroidsCount {
            centroids.append(CGPoint(x: CGFloat(randomDistributionX.nextInt()), y: CGFloat(randomDistributionY.nextInt())))
        }
        // sample gaussian points around each centroid
        for i in 0..<centroidsCount {
            let normalDistributionX = GKGaussianDistribution(randomSource: randomSource, lowestValue: Int(Int(centroids[i].x)-radius) , highestValue: Int(Int(centroids[i].x)+radius))
            let normalDistributionY = GKGaussianDistribution(randomSource: randomSource, lowestValue: Int(Int(centroids[i].y)-radius) , highestValue: Int(Int(centroids[i].y)+radius))
            for j in 0..<samplesForCentroid {
                trainData?.matrix.append(normalDistributionX.nextInt())
                trainData?.matrix.append(normalDistributionY.nextInt())
                trainData?.matrix.append(i)
                trainData?.append(index: j + i * samplesForCentroid)
            }
        }
        plot()
    }
    
    private func plot() {
        for subview in plotView.subviews {
            subview.removeFromSuperview()
        }
        if let dataset = trainData {
            for row in dataset.rows {
                let pointView = UIView(frame: CGRect(x: dataset.elementAt(row, 0), y: dataset.elementAt(row, 1), width: 5, height: 5))
                pointView.backgroundColor = UIColor.random(seed + "\(dataset.elementAt(row, 2))")
                pointView.layer.cornerRadius = 2.5
                plotView.addSubview(pointView)
            }
        }
        if let dataset = testData {
            for row in dataset.rows {
                let pointView = UIView(frame: CGRect(x: dataset.elementAt(row, 0), y: dataset.elementAt(row, 1), width: 5, height: 5))
                
                if let outputs = predictions {
                    pointView.backgroundColor = UIColor.random(seed + "\(outputs[row])")
                } else {
                    pointView.backgroundColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.0)
                }
                
                
                pointView.layer.cornerRadius = 2.5
                pointView.layer.borderColor = UIColor.black.cgColor
                pointView.layer.borderWidth = 0.5
                plotView.addSubview(pointView)
            }
        }

    }
}
