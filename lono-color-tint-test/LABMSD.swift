//
//  LABMSD.swift
//  lono-color-tint-test
//
//  Created by Priyam Mehta on 13/04/23.
//

import Foundation
import UIKit
import CoreImage
import Accelerate

func calculateMeanAndStandardDeviation(image: UIImage) -> (mean: Float, stdDev: Float)? {
    guard let ciImage = CIImage(image: image) else {
        return nil
    }

    let cubeData = generateLabcubeData()
    let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
    let filter = CIFilter(name: "CIColorCube", parameters: [
        "inputCubeDimension": 64,
        "inputCubeData": cubeData,
        "inputColorSpace": colorSpace,
        "inputImage": ciImage
    ])
    let outputCIImage = filter?.outputImage

    let context = CIContext()
    guard let outputCGImage = context.createCGImage(outputCIImage!, from: outputCIImage!.extent) else {
        return nil
    }

    let outputUIImage = UIImage(cgImage: outputCGImage)
    guard let cgImage = outputUIImage.cgImage else {
        return nil
    }

    let width = cgImage.width
    let height = cgImage.height
    let bytesPerPixel = 4 // RGBA
    let bytesPerRow = bytesPerPixel * width
    let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue

    guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else {
        return nil
    }

    context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
    guard let imageData = context.data else {
        return nil
    }

    let dataPointer = imageData.bindMemory(to: UInt8.self, capacity: width * height * bytesPerPixel)
    var lValues = [Float]()
    var aValues = [Float]()
    var bValues = [Float]()

    for i in 0..<width * height {
        let r = Float(dataPointer[i * bytesPerPixel])
        let g = Float(dataPointer[i * bytesPerPixel + 1])
        let b = Float(dataPointer[i * bytesPerPixel + 2])
        let a = Float(dataPointer[i * bytesPerPixel + 3])

        let ciColor = CIColor(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
        let lab = ciColor.colorConverted(to: CGColorSpaceCreateDeviceLab()!, intent: .defaultIntent)
        let l = Float(lab!.component(at: 0))
        let a = Float(lab!.component(at: 1))
        let b = Float(lab!.component(at: 2))

        lValues.append(l)
        aValues.append(a)
        bValues.append(b)
    }

    let meanL = lValues.reduce(0, +) / Float(lValues.count)
    let meanA = aValues.reduce(0, +) / Float(aValues.count)
    let meanB = bValues.reduce(0, +) / Float(bValues.count)

    let varianceL = lValues.map({ pow($0 - meanL, 2) }).reduce(0, +) / Float(lValues.count)
    let varianceA = aValues.map({ pow($0 - meanA, 2) }).reduce(0, +) / Float(aValues.count)
    let varianceB = bValues.map({ pow($0 - meanA, 2) }).reduce(0, +) / Float(bValues.count)

    let stdDevL = sqrt(varianceL)
    let stdDevA = sqrt(varianceA)
    let stdDevB = sqrt(varianceB)

    return (meanL, stdDevL, meanA, stdDevA, meanB, stdDevB)
}

func generateLabcubeData() -> Data {
    var cubeData = [Float]()
    for l in 0..<64 {
        for a in 0..<64 {
            for b in 0..<64 {
                let lValue = Float(l) * 255 / 63
                let aValue = Float(a) * 255 / 63
                let bValue = Float(b) * 255 / 63

                let ciColor = CIColor(color: UIColor(
                    _colorLiteralRed: lValue / 255,
                    green: aValue / 255,
                    blue: bValue / 255,
                    alpha: 1.0
                ))
                let lab = ciColor.colorConverted(to: CGColorSpaceCreateDeviceLab()!, intent: .defaultIntent)

                cubeData.append(Float(lab!.component(at: 0)) / 255)
                cubeData.append(Float(lab!.component(at: 1)) / 255)
                cubeData.append(Float(lab!.component(at: 2)) / 255)
                cubeData.append(1.0)
            }
        }
    }
    return Data(bytes: &cubeData, count: cubeData.count * MemoryLayout<Float>.size)
}

// Example usage with an UIImage object named "image":
//if let image = UIImage(named: "lab_image.jpg") {
//    if let labData = calculateMeanAndStandardDeviation(image: image) {
//        let (meanL, stdDevL, meanA, stdDevA, meanB, stdDevB) = labData
//        print("Mean L: \(meanL)")
//        print("Standard Deviation L: \(stdDevL)")
//        print("Mean A: \(meanA)")
//        print("Standard Deviation A: \(stdDevA)")
//        print("Mean B: \(meanB)")
//        print("Standard Deviation B: \(stdDevB)")
//    } else {
//        print("Failed to calculate LAB data")
//    }
//} else {
//    print("Failed to load image")
//}
