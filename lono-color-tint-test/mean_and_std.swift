//
//  mean_and_std.swift
//  lono-color-tint-test
//
//  Created by Priyam Mehta on 13/04/23.
//

import Foundation


func get_mean_and_std(lutData: NSData) -> ([Float],[Float])  {
//    let lutData: NSData = ... // Your LUT data
    let count = lutData.length / MemoryLayout<Float>.size
    var lutArray = [Float](repeating: 0, count: count)
    lutData.getBytes(&lutArray, length: count * MemoryLayout<Float>.size)

    var redValues = [Float]()
    var greenValues = [Float]()
    var blueValues = [Float]()

    for i in 0..<count/4 {
        let index = i * 4
        redValues.append(lutArray[index])
        greenValues.append(lutArray[index + 1])
        blueValues.append(lutArray[index + 2])
    }

    let redMean = redValues.reduce(0, +) / Float(redValues.count)
    let greenMean = greenValues.reduce(0, +) / Float(greenValues.count)
    let blueMean = blueValues.reduce(0, +) / Float(blueValues.count)
    
    let redStdDev = sqrt(redValues.map { pow($0 - redMean, 2) }.reduce(0, +) / Float(redValues.count))
    let greenStdDev = sqrt(greenValues.map { pow($0 - greenMean, 2) }.reduce(0, +) / Float(greenValues.count))
    let blueStdDev = sqrt(blueValues.map { pow($0 - blueMean, 2) }.reduce(0, +) / Float(blueValues.count))

    let meanRGBValues = [redMean, greenMean, blueMean]
    let stdRGBValues = [redStdDev, greenStdDev, blueStdDev]
    print(meanRGBValues) // Example output: [125.5, 255.0, 80.0]
    
    return (meanRGBValues, stdRGBValues)

}
