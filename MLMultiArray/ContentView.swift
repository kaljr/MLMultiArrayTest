//
//  ContentView.swift
//  MLMultiArray
//
//  Created by Kenny Langston on 2/3/21.
//

import SwiftUI
import CoreML

struct ContentView: View {
    let m = MLMultiTest()
    
    var body: some View {
        Text("Hello, world!")
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct MLMultiTest {
    init() {
        self.test()
    }
    
    // This is an exploration of how to work with MLMultiArray and its .dataPointer
    // property. This deals with linear offset indexing and standard array indexing
    // when working on a 4 dimensional CoreML result. The MLMultiArray is row-major,
    // meaning that if there are 4 (16x9) matrices, the first element [0,0,0,0] is
    // the top left corner of the first matrix. This is equal to the linear offset
    // position of 0 (pointer[0]). The next element on that first slice is [0,0,1,0]
    // but the linear offset is 4 because row-major ordering counts the top-left
    // corner of each matrix "slice" before counting the next element of the first.
    // Good resource:
    // https://eli.thegreenplace.net/2015/memory-layout-of-multi-dimensional-arrays
    func test() {
        // Define the desired array dimensions and create MLMultiArray
        let dims = [1,16,9,4] as [NSNumber]
        let numEls = 16 * 9 * 4 - 1
        let multiArr = try! MLMultiArray(shape: dims, dataType: .double)
        
        // Show the array strides. Multiplying these by the desired [i,j,k,l]
        // will yield the correct linear offset for the pointer.
        print("Strides:", multiArr.strides)
        
        // Get a pointer to the multiArray’s contents.
        let pointer = UnsafeMutablePointer<Double>(OpaquePointer(multiArr.dataPointer))
        
        // Set all values in the multiArray to 0.0
        for i in 0...numEls {
            pointer[i] = Double(0.0)
        }
        
        // Set desired elements to change
        let linearOffsets = [9, 343]
        
        // Set a unique value in the multiArray for desired elements
        let uniqueValue: Double = 5.0
        for i in 0...linearOffsets.count - 1 {
            pointer[linearOffsets[i]] = uniqueValue
        }
        
        // Iterate through all indexes to find the matching value
        for i in 0...dims[0].intValue - 1 {
            for j in 0...dims[1].intValue - 1 {
                for k in 0...dims[2].intValue - 1 {
                    for l in 0...dims[3].intValue - 1 {
                        let idx = [i, j, k, l] as [NSNumber]
                        
                        if (uniqueValue == multiArr[idx].doubleValue) {
                            print("Found matching elements at [", i, j, k, l, "] and ptr idx")
                            print("values", uniqueValue, multiArr[idx].doubleValue)
                        }
                    }
                }
            }
        }
    }
}


