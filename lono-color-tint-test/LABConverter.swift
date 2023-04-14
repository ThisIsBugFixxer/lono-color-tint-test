//
//  LABConverter.swift
//  lono-color-tint-test
//
//  Created by Priyam Mehta on 13/04/23.
//

import Foundation


import CoreImage


import UIKit

// Convert UIImage to LAB CIColorCube Data
func convertRGBToLAB(_ inputImage: UIImage) -> UIImage? {
    // Create a CIImage from the input UIImage
    guard let ciImage = CIImage(image: inputImage) else { return nil }
    
        let a = CGColorSpace(name: CGColorSpace.genericLab)!
    let b = CGColorSpaceCreateDeviceRGB()

    // Create a CIFilter to convert the image from RGB to LAB
    guard let colorFilter = CIFilter(name: "CIColorCube",
                                     parameters: [kCIInputImageKey: ciImage,
                                                  "inputSourceColorSpace": b,
                                                  "inputDestinationColorSpace": a ])
    else { return nil }

    // Get the output image from the filter
    guard let outputImage = colorFilter.outputImage else { return nil }

    // Create a context and render the image
    let context = CIContext(options: nil)
    guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }

    // Convert the CGImage back to UIImage and return
    return UIImage(cgImage: cgImage)
}
//func convertToLAB(image: UIImage, dimension: Int) -> Data? {
//    guard let cgImage = image.cgImage else { return nil }
//    let width = cgImage.width
//    let height = cgImage.height
//    let bytesPerPixel = 4
//    let bytesPerRow = bytesPerPixel * width
//    let totalBytes = bytesPerRow * height
//    let colorSpace = CGColorSpaceCreateDeviceRGB()
//    let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
//    let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
//    context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
//    guard let data = context?.data else { return nil }
//
//    var labData = Data()
//    for i in 0..<(totalBytes / bytesPerPixel) {
//        let r = Float(data.load(fromByteOffset: i * bytesPerPixel + 0, as: UInt8.self)) / 255.0
//        let g = Float(data.load(fromByteOffset: i * bytesPerPixel + 1, as: UInt8.self)) / 255.0
//        let b = Float(data.load(fromByteOffset: i * bytesPerPixel + 2, as: UInt8.self)) / 255.0
//        let labColor = LABColor(rgbColor: RGBColor(r: r, g: g, b: b))
//        labData.append(UInt8(labColor.l * 255.0))
//        labData.append(UInt8(labColor.a * 255.0))
//        labData.append(UInt8(labColor.b * 255.0))
//        labData.append(255)
//    }
//
//    let lutDimension = min(dimension, 128)
//    let cubeData = createLABColorCubeData(dimension: lutDimension)
//    labData.append(cubeData)
//
//    return labData
//}
//
//// LABColor struct for representing colors in LAB color space
//struct LABColor {
//    let l: Float
//    let a: Float
//    let b: Float
//
//    init(rgbColor: RGBColor) {
//        let xyzColor = rgbColor.toXYZColor()
//        let l = fmaxf(0.0, 116.0 * xyzColor.y - 16.0)
//        let a = (xyzColor.x - xyzColor.y) * 500.0
//        let b = (xyzColor.y - xyzColor.z) * 200.0
//        self.l = l / 100.0
//        self.a = a / 127.0
//        self.b = b / 127.0
//    }
//}
//
//// RGBColor struct for representing colors in RGB color space
//struct RGBColor {
//    let r: Float
//    let g: Float
//    let b: Float
//
//    func toXYZColor() -> XYZColor {
//        let r = self.r > 0.04045 ? powf((self.r + 0.055) / 1.055, 2.4) : self.r / 12.92
//        let g = self.g > 0.04045 ? powf((self.g + 0.055) / 1.055, 2.4) : self.g / 12.92
//        let b = self.b > 0.04045 ? powf((self.b + 0.055) / 1.055, 2.4) : self.b / 12.92
//        let x = r * 0.4124564 + g * 0.3575761 + b * 0.1804375
//        let y = r * 0.2126729 + g * 0.7151522 + b * 0.0721750
//        let z = r * 0.0193339 + g * 0.1191920 + b * 0.9503041
//
//        return XYZColor(x: x, y: y, z: z)
//    }
//}
//
//// XYZColor struct for representing colors in XYZ color space
//struct XYZColor {
//let x: Float
//let y: Float
//let z: Float
//}
//
//// Create LAB color cube data for CIColorCube filter
//func createLABColorCubeData(dimension: Int) -> Data {
//var cubeData = Data()
//for z in 0..<dimension {
//let b = Float(z) / Float(dimension - 1)
//for y in 0..<dimension {
//let g = Float(y) / Float(dimension - 1)
//for x in 0..<dimension {
//let r = Float(x) / Float(dimension - 1)
//    let labColor = LABColor(rgbColor: RGBColor(r:r, g:g, b:b))
//cubeData.append(UInt8(labColor.l * 255.0))
//cubeData.append(UInt8(labColor.a * 255.0))
//cubeData.append(UInt8(labColor.b * 255.0))
//cubeData.append(255)
//}
//}
//}
//return cubeData
//}
//
//
//// Convert LAB CIColorCube Data to UIImage
//func convertLABToUIImage(labData: Data, width: Int, height: Int) -> UIImage? {
//    let colorSpace = CGColorSpaceCreateDeviceRGB()
//    let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
//    let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 4 * width, space: colorSpace, bitmapInfo: bitmapInfo)
//    guard let ctx = context else { return nil }
//
//    labData.withUnsafeBytes { (ptr: UnsafePointer<UInt8>) in
//        ctx.data?.copyMemory(from: ptr, byteCount: width * height * 4)
//    }
//
//    guard let cgImage = ctx.makeImage() else { return nil }
//    let image = UIImage(cgImage: cgImage)
//
//    return image
//}
//
//
//func LABConverter(image: UIImage, dimension: Int) -> UIImage {
//    let ct = convertToLAB(image: image, dimension: dimension)!
//    return convertLABToUIImage(labData: ct, width: Int(image.size.width), height: Int(image.size.height))!
//
//}
