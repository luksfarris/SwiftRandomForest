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

class TreeNode<T:Numeric> {
    
    public private(set) var bestIndex:Int?
    public private(set) var bestGroup:Group<T>?
    public private(set) var bestValue:T?
    public private(set) var terminalValue:T?
    
    public var left:TreeNode<T>?
    public var right:TreeNode<T>?
    
    init(bestIndex: Int, bestValue:T?, bestGroup:Group<T>?) {
        self.bestIndex = bestIndex
        self.bestValue = bestValue
        self.bestGroup = bestGroup
    }
    
    init(terminalValue:T?) {
        self.terminalValue = terminalValue
    }
}

struct Group<T:Numeric> {
    public private(set) var left:MatrixReference<T>
    public private(set) var right:MatrixReference<T>
    
    init(left:MatrixReference<T>, right:MatrixReference<T>) {
        self.left = left
        self.right = right
    }
}
