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

enum MetricType {
    case accuracy
    case kappa
}



class Metrics<T:Numeric> {
    
    public static func metric(_ type:MetricType, actual:Array<T>, predicted:Array<T>) -> Double {
        switch type {
        case .accuracy:
            return accuracyMetric(actual: actual, predicted: predicted)
        case .kappa:
            return kappaMetric(actual: actual, predicted: predicted)
        }
    }
    
    private static func kappaMetric(actual:Array<T>, predicted:Array<T>) -> Double {
        var truePositive = 0.0, falsePositive = 0.0, falseNegative = 0.0, trueNegative = 0.0
        
        let falseValue = T.parse(text: "\(0)")
        let trueValue = T.parse(text: "\(1)")
        
        for i in 0..<actual.count {
            if actual[i] == falseValue &&  predicted[i] == falseValue {
                falseNegative += 1
            } else if actual[i] == falseValue &&  predicted[i] == trueValue {
                falsePositive = 1
            } else if actual[i] == trueValue &&  predicted[i] == trueValue {
                truePositive += 1
            } else {
                trueNegative += 1
            }
        }
        let a:Double=truePositive, b:Double=trueNegative, c:Double=falsePositive, d:Double=falseNegative
        
        let p0:Double = (a+d)/(a+b+c+d)
        let marginalA:Double = (a+b)*(a+c)/(a+b+c+d)
        let marginalB:Double = (c+b)*(c+d)/(a+b+c+d)
        let pE:Double = (marginalA+marginalB)/(a+b+c+d)
        let k:Double = (p0-pE)/(1-pE)
        return k
    }
    
    private static func accuracyMetric(actual:Array<T>, predicted:Array<T>) -> Double {
        var correct = 0
        for i in 0..<actual.count {
            if actual[i] == predicted[i] {
                correct += 1
            }
        }
        return Double(correct)/Double(actual.count)
    }
}
