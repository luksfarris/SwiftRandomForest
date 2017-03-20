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

class BenchmarkTest {
    var mat:MatrixBenchmark
    var count:Int
    init (count:Int) {
        self.count = count
        mat = MatrixBenchmark.init(rows: count)
    }
    func printTimeElapsedWhenRunningCode(title:String, operation:()->()) {
        let startTime = CFAbsoluteTimeGetCurrent()
        operation()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        print("\(title): \(timeElapsed) s")
    }
    
    func beginTestingAlloc() {
        
        printTimeElapsedWhenRunningCode(title: "Array Alloc") {
            for _ in 0..<1000 {
                mat.matrixArray = Array(repeating:0, count:1000)
            }
        }
        
        printTimeElapsedWhenRunningCode(title: "NSMutableArray Alloc") {
            for _ in 0..<1000 {
                mat.matrixNSArray = NSMutableArray.init(capacity: 1000)
            }
        }
        
        printTimeElapsedWhenRunningCode(title: "UnsafeMutablePointer Alloc") {
            for _ in 0..<1000 {
                mat.matrixPointer.deallocate(capacity: 100*10 * MemoryLayout<Int>.size)
                mat.matrixPointer = UnsafeMutablePointer<Int>.allocate(capacity: 1000 * MemoryLayout<Int>.size)
            }
        }
    }
    
    func begin() {
        self.beginTestingAccess()
    }
    
    func beginTestingAccess() {
        printTimeElapsedWhenRunningCode(title: "Array Access") {
            mat.minArray()
        }
        printTimeElapsedWhenRunningCode(title: "NSMutableArray Access") {
            mat.minNSArray()
        }
        printTimeElapsedWhenRunningCode(title: "Pointer Access") {
            mat.minPointer()
        }
        self.beginTestingAlloc()
    }
}

struct MatrixBenchmark {
    var cols:Int = 10, rows:Int
    var matrixArray:Array<Int>
    var matrixNSArray:NSMutableArray
    var matrixPointer:UnsafeMutablePointer<Int>
    init(rows:Int) {
        self.rows = rows
        matrixArray = Array(repeating:0, count:cols*rows)
        matrixNSArray = NSMutableArray.init(capacity: cols*rows)
        matrixPointer = UnsafeMutablePointer<Int>.allocate(capacity: cols * rows * MemoryLayout<Int>.size)
        
        let source = GKARC4RandomSource(seed: "EquinociOS".data(using: .utf8)!)
        source.dropValues(777)
        
        for i in 0..<cols*rows {
            let rand = Int(source.nextInt())
            matrixArray[i] = rand
            matrixNSArray[i] = rand
            matrixPointer[i] = rand
        }
    }

    func minPointer () {
        for index in 0..<self.rows {
            var min = 10
            for i in index*cols..<(index*cols+1) {
                let value = self.matrixPointer[i]
                if value<min {
                    min = value
                }
            }
        }
    }
    
    func minNSArray () {
        for index in 0..<self.rows {
            var min = 10
            for i in index*cols..<(index*cols+1) {
                let value = self.matrixNSArray[i] as! Int
                if value < min {
                    min = value
                }
            }
        }
    }
    
    func minArray () {
        for index in 0..<self.rows {
            var min = 10
            for i in index*cols..<(index*cols+1) {
                let value = self.matrixArray[i]
                if value<min {
                    min = value
                }
            }
        }
    }
}
