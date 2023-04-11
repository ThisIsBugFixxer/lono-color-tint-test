//
//  reinhardColorTransfer.swift
//  lono-color-tint-test
//
//  Created by Priyam Mehta on 11/04/23.
//

import Foundation

import UIKit
import CoreImage

func getAvgStd(image: CIImage) -> (avg: [CGFloat], std: [CGFloat]) {
    
        let inputKeys = ["inputImage", "inputExtent"]
        let outputKeys = ["outputAverage", "outputHistogram"]
        let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: image])
        let avgImage = filter?.outputImage

        // Render CIImage into CGImage
        let context = CIContext(options: nil)
        if let avgCGImage = context.createCGImage(avgImage!, from: (avgImage?.extent)!) {
            // Get pixel data from CGImage
            let dataProvider = avgCGImage.dataProvider
            let data = dataProvider?.data
            let buffer = CFDataGetBytePtr(data)
            
            let image_avg_l = CGFloat(buffer![0])
            let image_avg_a = CGFloat(buffer![1])
            let image_avg_b = CGFloat(buffer![2])
            
            let std = [
                CGFloat(sqrt(pow(Double(buffer![0]), 2.0))),
                CGFloat(sqrt(pow(Double(buffer![1]), 2.0))),
                CGFloat(sqrt(pow(Double(buffer![2]), 2.0)))
            ]
            
            return (avg: [image_avg_l, image_avg_a, image_avg_b], std: std)
        } else {
            // Return default values or handle error as needed
            return (avg: [0, 0, 0], std: [0, 0, 0])
        }
}

func processImage(src: UIImage, des: UIImage) -> UIImage? {
    guard let srcCIImage = CIImage(image: src), let desCIImage = CIImage(image: des) else {
        return nil
    }

    let (srcAvg, _) = getAvgStd(image: srcCIImage)
    let (desAvg, _) = getAvgStd(image: desCIImage)

    let params: [String: Any] = [
        "inputImage": desCIImage,
        "inputBiasVector": CIVector(x: srcAvg[0] - desAvg[0], y: srcAvg[1] - desAvg[1], z: srcAvg[2] - desAvg[2], w: 0),
        "inputRVector": CIVector(x: 1, y: 0, z: 0, w: 0),
        "inputGVector": CIVector(x: 0, y: 1, z: 0, w: 0),
        "inputBVector": CIVector(x: 0, y: 0, z: 1, w: 0),
        "inputAVector": CIVector(x: 0, y: 0, z: 0, w: 1)
    ]

    let filter = CIFilter(name: "CIColorMatrix", parameters: params)
    filter!.setValue(desCIImage, forKey: kCIInputImageKey)
    let outputImage = filter?.outputImage

    let context = CIContext(options: nil)
    if let cgImage = context.createCGImage(outputImage!, from: outputImage!.extent) {
        return UIImage(cgImage: cgImage)
    } else {
        return nil
    }
}
