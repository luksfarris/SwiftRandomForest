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

class CSVReader<T:Numeric>: NSObject {

    private var encoding:String.Encoding = .utf8
    private var hasHeader:Bool = false
    
    init(encoding:String.Encoding, hasHeader:Bool) {
        self.encoding = encoding
        self.hasHeader = hasHeader
    }
    
    private func stringFromFile(filename:String) -> String? {
        let bundle = Bundle.main;
        let path = bundle.path(forResource:filename, ofType:"csv")
        if let validPath = path {
            do {
                let response = try NSData(contentsOfFile: validPath, options: .mappedIfSafe)
                let text = String(data: Data.init(referencing:response), encoding: self.encoding)
                if let validText = text {
                    return validText
                } else {
                    print ("Bad encoding")
                }
            } catch {
                print("Error reading file")
            }
        } else {
            print("Bad path")
        }
        return nil
    }
    
    
    public func parseFileWith(name:String) -> Matrix<T>? {
        if let file = self.stringFromFile(filename: name) {
            let allLines = file.components(separatedBy: NSCharacterSet.newlines)
            let features = allLines[0].components(separatedBy: ",")
            
            let badLines = 1 + (hasHeader ? 1:0)
            
            let dataset = Matrix<T>.init(rows: allLines.count-badLines, columns: features.count)
            dataset.outputClasses = []
            
            for line in allLines {
                if (hasHeader) {
                    hasHeader = false;
                    continue
                }
                if (line==""){
                    continue
                }
                let textFeatures = line.components(separatedBy: ",")
                let numberFeatures = textFeatures.map({ (feat:String) -> T in
                    return T.parse(text: feat)
                })
                
                for feat in numberFeatures {
                    dataset.append(feat)
                }
                
                if (!dataset.outputClasses!.contains(numberFeatures[features.count-1])) {
                    dataset.outputClasses!.append(numberFeatures[features.count-1])
                }
            }
            return dataset
        }
        return nil
    }
}
