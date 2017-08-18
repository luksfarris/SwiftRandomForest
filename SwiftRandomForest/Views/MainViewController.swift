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

class MainViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var implementedAlgorithms:[String] = [SupervisedLearning.randomForest.rawValue, UnsupervisedLearning.kMeans.rawValue]
    fileprivate var supervisedAlgorithms:[SupervisedLearning] = [.randomForest, .kNearestNeighbors, .gradientBoosting, .naïveBayes, .supportVectorMachines]
    fileprivate var unsupervisedAlgorithms:[UnsupervisedLearning] = [.kMeans, .neuralNetworks, .deepLearning]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! VisualizeViewController
        if let algorithm = sender as? SupervisedLearning {
            if (algorithm == SupervisedLearning.randomForest) {
                destination.classifier = RandomForest<Int>.init(seed:"Seed", outputClasses: Array(0..<destination.centroidsCount))
                destination.supervised = true
            }
        } else if let algorithm = sender as? UnsupervisedLearning {
            if (algorithm == UnsupervisedLearning.kMeans) {
                destination.classifier = KMeans.init(seed: "Seed")
                destination.supervised = false
            }
        }
    }
}

extension MainViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var algorithm:Any? = nil
        if indexPath.section == 0 {
            algorithm = supervisedAlgorithms[indexPath.row]
        } else {
            algorithm = unsupervisedAlgorithms[indexPath.row]
        }
        performSegue(withIdentifier: "visualize", sender: algorithm)
    }
}

extension MainViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 0) ? supervisedAlgorithms.count : unsupervisedAlgorithms.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Supervised Algorithms"
        } else {
            return "Unsupervised Algorithms"
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        var title:String = ""
        if indexPath.section == 0 {
            title = supervisedAlgorithms[indexPath.row].rawValue
        } else {
            title = unsupervisedAlgorithms[indexPath.row].rawValue
        }
        cell.textLabel?.text = title
        if implementedAlgorithms.contains(title) {
            cell.isUserInteractionEnabled = true
            cell.selectionStyle = .gray
            cell.textLabel?.textColor = UIColor.black
        } else {
            cell.isUserInteractionEnabled = false
            cell.selectionStyle = .none
            cell.textLabel?.textColor = UIColor.lightGray
        }
        return cell
    }
}

