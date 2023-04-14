////
////  CIImage+Extensions.swift
////  color-tint-test
////
////  Created by Priyam Mehta on 11/04/23.
////
//
import Foundation
import CoreImage

extension CGImage {
    func applyingReinhardColorTransfer(withSourceLUTData sourceLUTData: NSData, targetLUTData: NSData, lutDimension: Int) -> CGImage? {
        // Create a CIImage from the source CGImage
        let sourceCIImage = CIImage(cgImage: self)

        // Create a CIFilter for CIColorCube
        let sourceColorCubeFilter = CIFilter(name: "CIColorCube")!
        sourceColorCubeFilter.setValue(sourceCIImage, forKey: kCIInputImageKey)
        sourceColorCubeFilter.setValue(sourceLUTData, forKey: "inputCubeData")
        sourceColorCubeFilter.setValue(lutDimension, forKey: "inputCubeDimension")

        // Apply the source colorCubeFilter to get the output CIImage
        guard let sourceOutputImage = sourceColorCubeFilter.outputImage else {
            print("Failed to get outputImage from sourceColorCubeFilter")
            return nil
        }

        // Create a CIImage from the target LUT data
        let targetCIImage = CIImage(bitmapData: targetLUTData as Data, bytesPerRow: lutDimension * 4 * MemoryLayout<Float>.size, size: CGSize(width: lutDimension * lutDimension, height: lutDimension), format: .RGBA8, colorSpace: CGColorSpaceCreateDeviceRGB())

        // Create a CIFilter for CIColorCube
        let targetColorCubeFilter = CIFilter(name: "CIColorCube")!
        targetColorCubeFilter.setValue(targetCIImage, forKey: "inputCubeData")
        targetColorCubeFilter.setValue(lutDimension, forKey: "inputCubeDimension")

        // Apply the target colorCubeFilter to get the output CIImage
        guard let targetOutputImage = targetColorCubeFilter.outputImage else {
            print("Failed to get outputImage from targetColorCubeFilter")
            return nil
        }

        // Create a CIFilter for CISourceOverCompositing
        let compositingFilter = CIFilter(name: "CISourceOverCompositing")!
        compositingFilter.setValue(sourceOutputImage, forKey: kCIInputImageKey)
        compositingFilter.setValue(targetOutputImage, forKey: kCIInputBackgroundImageKey)

        // Apply the compositing filter to get the output CIImage
        guard let compositingOutputImage = compositingFilter.outputImage else {
            print("Failed to get outputImage from compositingFilter")
            return nil
        }

        // Create a CIContext for rendering the output CIImage
        let ciContext = CIContext(options: nil)

        // Render the output CIImage to a CGImage
        guard let outputCGImage = ciContext.createCGImage(compositingOutputImage, from: compositingOutputImage.extent) else {
            print("Failed to create CGImage from outputImage")
            return nil
        }

        // Return the resulting CGImage
        return outputCGImage
    }
}
