////
////  CIImage+Extensions.swift
////  color-tint-test
////
////  Created by Priyam Mehta on 11/04/23.
////
//
//import Foundation
//import CoreImage
//
//extension CIImage {
//    func getRGBHistogram() -> (red: [UInt], green: [UInt], blue: [UInt]) {
//        let histogramSize = 256
//        var histogramR = [UInt](repeating: 0, count: histogramSize)
//        var histogramG = [UInt](repeating: 0, count: histogramSize)
//        var histogramB = [UInt](repeating: 0, count: histogramSize)
//
//        let context = CIContext(options: nil)
//        if let cgImage = context.createCGImage(self, from: self.extent) {
//            let imageData = cgImage.dataProvider?.data
//            if let data = imageData {
//                let mutableData = CFDataCreateMutableCopy(nil, 0, data)
//                    let buffer = CFDataGetMutableBytePtr(mutableData)
//                    let count = CFDataGetLength(mutableData)
//                if let buffer = buffer {
//                        for i in 0..<count {
//                            let value = buffer[i]
//                            // Perform operations on the value, e.g. histogram calculation, color transfer, etc.
//                        }
//                    }
//
////                let pixelBuffer = buffer.baseAddress!.assumingMemoryBound(to: UInt32.self)
//                let pixelCount = count / MemoryLayout<UInt32>.size
//
//                for i in 0..<pixelCount {
//                    let pixel = pixelBuffer[i]
//                    let r = UInt8((pixel >> 16) & 0xff)
//                    let g = UInt8((pixel >> 8) & 0xff)
//                    let b = UInt8(pixel & 0xff)
//                    histogramR[Int(r)] += 1
//                    histogramG[Int(g)] += 1
//                    histogramB[Int(b)] += 1
//                }
//            }
//        }
//
//        return (histogramR, histogramG, histogramB)
//    }
//
//    func mean() -> (red: Float, green: Float, blue: Float) {
//        let histogram = self.getRGBHistogram()
//        let pixelCount = self.extent.width * self.extent.height
//        let sumR = histogram.red.enumerated().reduce(0) { $0 + Float($1.offset) * Float($1.element) }
//        let sumG = histogram.green.enumerated().reduce(0) { $0 + Float($1.offset) * Float($1.element) }
//        let sumB = histogram.blue.enumerated().reduce(0) { $0 + Float($1.offset) * Float($1.element) }
//        let meanR = sumR / Float(pixelCount)
//        let meanG = sumG / Float(pixelCount)
//        let meanB = sumB / Float(pixelCount)
//        return (meanR, meanG, meanB)
//    }
//
//    func standardDeviation() -> (red: Float, green: Float, blue: Float) {
//        let histogram = self.getRGBHistogram()
//        let pixelCount = self.extent.width * self.extent.height
//        let mean = self.mean()
//        let sumR = histogram.red.enumerated().reduce(0) { $0 + Float($1.offset) * Float($1.offset) * Float($1.element) }
//        let sumG = histogram.green.enumerated().reduce(0) { $0 + Float($1.offset) * Float($1.offset) * Float($1.element) }
//        let sumB = histogram.blue.enumerated().reduce(0) { $0 + Float($1.offset) * Float($1.offset) * Float($1.element) }
//        let varianceR = (sumR / Float(pixelCount)) - (mean.red * mean.red)
//        let varianceG = (sumG / Float(pixelCount)) - (mean.green * mean.green)
//        let varianceB = (sumB / Float(pixelCount)) - (mean.blue * mean.blue)
//        let stdDevR = sqrt(max(0, varianceR))
//        let stdDevG = sqrt(max(0, varianceG))
//        let stdDevB = sqrt(max(0, varianceB))
//        return (stdDevR, stdDevG, stdDevB)
//    }
//}
//
//func colorTransfer(sourceImage: CIImage, targetImage: CIImage) -> CIImage? {
//    let sourceMean = sourceImage.mean()
//    let sourceStdDev = sourceImage.standardDeviation()
//    let targetMean = targetImage.mean()
//    let targetStdDev = targetImage.standardDeviation()
//
//    guard let sourceRgbFilter = CIFilter(name: "CIColorMatrix"),
//          let targetRgbFilter = CIFilter(name: "CIColorMatrix") else {
//        return nil
//    }
//
//    sourceRgbFilter.setValue(sourceMean.red - targetMean.red, forKey: "inputBiasR")
//    sourceRgbFilter.setValue(sourceMean.green - targetMean.green, forKey: "inputBiasG")
//    sourceRgbFilter.setValue(sourceMean.blue - targetMean.blue, forKey: "inputBiasB")
//    sourceRgbFilter.setValue(sourceStdDev.red / targetStdDev.red, forKey: "inputScaleR")
//    sourceRgbFilter.setValue(sourceStdDev.green / targetStdDev.green, forKey: "inputScaleG")
//    sourceRgbFilter.setValue(sourceStdDev.blue / targetStdDev.blue, forKey: "inputScaleB")
//
//    targetRgbFilter.setValue(targetMean.red, forKey: "inputBiasR")
//    targetRgbFilter.setValue(targetMean.green, forKey: "inputBiasG")
//    targetRgbFilter.setValue(targetMean.blue, forKey: "inputBiasB")
//    targetRgbFilter.setValue(targetStdDev.red, forKey: "inputScaleR")
//    targetRgbFilter.setValue(targetStdDev.green, forKey: "inputScaleG")
//    targetRgbFilter.setValue(targetStdDev.blue, forKey: "inputScaleB")
//
//    let sourceRgbOutput = sourceRgbFilter.outputImage?.cropped(to: sourceImage.extent)
//    let targetRgbOutput = targetRgbFilter.outputImage?.cropped(to: targetImage.extent)
//
//    guard let sourceRgb = sourceRgbOutput, let targetRgb = targetRgbOutput else {
//        return nil
//    }
//
//    let combinedFilter = CIFilter(name: "CISourceOverCompositing")
//    combinedFilter?.setValue(sourceRgb, forKey: "inputImage")
//    combinedFilter?.setValue(targetRgb, forKey: "inputBackgroundImage")
//
//    let outputImage = combinedFilter?.outputImage?.cropped(to: sourceImage.extent)
//
//    return outputImage
//}
