//
//  ViewController.swift
//  color-tint-test
//
//  Created by Priyam Mehta on 11/04/23.
//

import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit
import AVFoundation
import AVKit
import PhotosUI


class ViewController: UIViewController, PHPickerViewControllerDelegate, UITextFieldDelegate {
    
    var selectedImages: [UIImage] = []
    
    @IBOutlet weak var valueSlider: UISlider!
    @IBOutlet weak var inputLbl: UITextField!
    

    @IBOutlet weak var btn4: UIButton!
    @IBOutlet weak var img3view: UIImageView!
    @IBOutlet weak var btn3: UIButton!
    @IBOutlet weak var btn2: UIButton!
    @IBOutlet weak var opImgView: UIImageView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var btn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        valueSlider.minimumValue = 2
        valueSlider.maximumValue = 64
        valueSlider.isContinuous = true
        valueSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        inputLbl.keyboardType = .numberPad
        inputLbl.delegate = self
        imgView.image = UIImage(named: "pic7")
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
    @objc func sliderValueChanged() {
            let value = Int(valueSlider.value)
        btn4.setTitle("\(value)", for: .normal)
        
        lutColorTransfer()
        
        }
    
    
    @IBAction func btnOnClick(_ sender: Any) {
        // Load the image
       
        // Load the image
        let image = imgView.image

        // Convert the UIImage to CIImage
        guard let ciImage = CIImage(image: image!) else { return }

        // Get the user input color
        let userInputColor = UIColor.green // Replace with the actual user input color
        var hue: CGFloat = 0.0
        var saturation: CGFloat = 0.0
        var brightness: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        userInputColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)

        // Adjust brightness, contrast, and saturation
        let darkerBrightness: CGFloat = 0.3 // Replace with the desired darker brightness value
        let contrast: CGFloat = 1.0 // Replace with the desired contrast value
        let saturationValue: CGFloat = 1.0 // Replace with the desired saturation value

        brightness *= darkerBrightness

        // Apply the color tint
        let hueFilter = CIFilter.hueAdjust()
        hueFilter.inputImage = ciImage
        hueFilter.angle = Float(hue * 2 * .pi) // Convert hue from UIColor to radians

        // Create a color matrix filter to adjust brightness
        let colorMatrixFilter = CIFilter.colorMatrix()
        colorMatrixFilter.inputImage = hueFilter.outputImage
        colorMatrixFilter.rVector = CIVector(x: 1, y: 0, z: 0, w: 0)
        colorMatrixFilter.gVector = CIVector(x: 0, y: 1, z: 0, w: 0)
        colorMatrixFilter.bVector = CIVector(x: 0, y: 0, z: 1, w: 0)
        colorMatrixFilter.aVector = CIVector(x: 0, y: 0, z: 0, w: 1)
        colorMatrixFilter.biasVector = CIVector(x: 0, y: 0, z: 0, w: CGFloat(Float(brightness)))

        // Create a color controls filter to adjust contrast and saturation
        let colorControlsFilter = CIFilter.colorControls()
        colorControlsFilter.inputImage = colorMatrixFilter.outputImage
        colorControlsFilter.contrast = Float(contrast)
        colorControlsFilter.saturation = Float(saturationValue)

        guard let outputCIImage = colorControlsFilter.outputImage else { return }

        // Convert the CIImage to UIImage
        let context = CIContext()
        guard let outputCGImage = context.createCGImage(outputCIImage, from: ciImage.extent) else { return }
        let outputImage = UIImage(cgImage: outputCGImage)

        opImgView.image = outputImage
    

        // Now you can use the outputImage UIImage object, which will be the original image with the color tint applied based on the user input color.

       
    }
    
    
    @IBAction func btn2OnClick(_ sender: Any) {
     
        // Load the input image
        let inputImage = imgView.image! // Replace with your own image

        // Create a CIImage from the input image
        guard let ciImage = CIImage(image: inputImage) else { return }
        
        // Define the RGB values for the tint color
        // Define the RGB values for the tint color
        let r: CGFloat = 0.0 // Replace with your desired red value (0.0 - 1.0)
        let g: CGFloat = 1.0 // Replace with your desired green value (0.0 - 1.0)
        let b: CGFloat = 0.0 // Replace with your desired blue value (0.0 - 1.0)

        // Define the scale factor for the tint color
        let scaleFactor: CGFloat = 2.0 // Replace with your desired scale factor (0.0 - 1.0)

        // Calculate the scaled RGB values for the color cube
        let scaledR = r * scaleFactor
        let scaledG = g * scaleFactor
        let scaledB = b * scaleFactor

        // Create a color cube filter
        let colorCubeFilter = CIFilter.colorCube()

        // Define the color cube data
        let dimension = 64 // Dimension of the color cube
        let cubeDataSize = dimension * dimension * dimension * MemoryLayout<Float>.size * 4
        var cubeData = [Float](repeating: 0, count: cubeDataSize)
        for i in 0..<dimension {
            for j in 0..<dimension {
                for k in 0..<dimension {
                    let index = (i * dimension * dimension + j * dimension + k) * 4
                    cubeData[index] = Float(scaledR) * Float(i) / Float(dimension - 1) // Red component
                    cubeData[index + 1] = Float(scaledG) * Float(j) / Float(dimension - 1) // Green component
                    cubeData[index + 2] = Float(scaledB) * Float(k) / Float(dimension - 1) // Blue component
                    cubeData[index + 3] = 0.5 // Alpha component
                }
            }
        }


        // Convert the color cube data to NSData
        let cubeDataNSData = NSData(bytes: &cubeData, length: cubeDataSize)

        // Set the color cube parameters
        colorCubeFilter.inputImage = ciImage
        colorCubeFilter.cubeDimension = Float(dimension)
        colorCubeFilter.cubeData = cubeDataNSData as Data

        // Apply the color cube filter
        guard let outputCIImage = colorCubeFilter.outputImage else { return }

        // Convert the CIImage to a UIImage
        let context = CIContext(options: nil)
        guard let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else { return }
        let outputImage = UIImage(cgImage: outputCGImage)

        // Display the output image
        
    
        opImgView.image = outputImage

        
//        // Example usage:
//        let sourceImage = UIImage(named: "pic")!
//        let targetImage = UIImage(named: "pic2")!
//        let rct = reinhardColorTransfer(sourceImage: sourceImage, targetImage: targetImage)
//        let outputImage = rct.mainReinhardColorTransfer(sourceImage: sourceImage, targetImage: targetImage)
//        opImgView.image = outputImage
//        // OutputImage now contains the result of Reinhard color transfer from sourceImage to targetImage
    }
    
    @IBAction func btn3OnClick(_ sender: Any) {
        
        if selectedImages.count == 2 {
            selectedImages = []
        }
        
        var configuration = PHPickerConfiguration()
               configuration.filter = .images
               configuration.selectionLimit = 1 // set to 0 for unlimited selection
               
               let picker = PHPickerViewController(configuration: configuration)
               picker.delegate = self
               present(picker, animated: true, completion: nil)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
           dismiss(animated: true, completion: nil)
           
           for result in results {
               if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                   result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                       guard let self = self, let image = image as? UIImage else {
                           return
                       }
                       
                       DispatchQueue.main.async {
                           self.selectedImages.append(image)
                           // do something with the selectedImages array, such as displaying the images in a collection view
                       }
                   }
               }
           }
       }
       
       func pickerDidCancel(_ picker: PHPickerViewController) {
           dismiss(animated: true, completion: nil)
       }
    @IBAction func btn4OnClick(_ sender: Any) {
//        colorTransfer()
        
//      lutColorTransfer()
        
//        reinhardLutColortransfer()
        
        lutColorTransferReinEasy()
        
        

       


    }
    
    func lutColorTransferReinEasy() {
        /////////////////////////////  SOURCE IMAGE
        // Load the image from a UIImage or a file URL
        let image = convertRGBToLAB(selectedImages[0])!

        // Get the CGImage from the UIImage
        guard let cgImage = image.cgImage else {
            print("Failed to get CGImage from image")
            return
        }

        // Get the size of the image
        let width = cgImage.width
        let height = cgImage.height

        // Create an empty array to store the LUT
        
        let lutDimens = 64 //Int(valueSlider.value)// Int(inputLbl.text!)!
        btn4.setTitle("\(lutDimens)", for: .normal)
        var lut = [Float](repeating: 0, count: lutDimens * lutDimens * lutDimens * 4)

        // Extract the color data from the image
        guard let imageData = cgImage.dataProvider?.data else {
            print("Failed to get image data")
            return
        }

        let data = CFDataGetBytePtr(imageData)

        // Populate the LUT with color values
        for i in 0..<lutDimens {
            for j in 0..<lutDimens {
                for k in 0..<lutDimens {
                    let index = (i * lutDimens * lutDimens) + (j * lutDimens) + k
                    lut[index * 4] = Float(data![index * 4]) / 255.0  // Red channel
                    lut[index * 4 + 1] = Float(data![index * 4 + 1]) / 255.0  // Green channel
                    lut[index * 4 + 2] = Float(data![index * 4 + 2]) / 255.0  // Blue channel
                    lut[index * 4 + 3] = 1.0  // Alpha channel
                }
            }
        }

        // Convert the lut array to NSData
        let lutData = NSData(bytes: lut, length: lut.count * MemoryLayout<Float>.size)

        //////////////////// TARGET IMAGE
        let inputImage = CIImage(image: convertRGBToLAB(selectedImages[1])!)!
        
        guard let cgImageip = inputImage.cgImage else {
            print("Failed to get CGImage from image")
            return
        }

        // Get the size of the image
        let widthip = cgImageip.width
        let heightip = cgImageip.height

        // Create an empty array to store the LUT
        
        
        btn4.setTitle("\(lutDimens)", for: .normal)
        var lutip = [Float](repeating: 0, count: lutDimens * lutDimens * lutDimens * 4)

        // Extract the color data from the image
        guard let imageDataip = cgImageip.dataProvider?.data else {
            print("Failed to get image data")
            return
        }

        let dataip = CFDataGetBytePtr(imageDataip)

        // Populate the LUT with color values
        for i in 0..<lutDimens {
            for j in 0..<lutDimens {
                for k in 0..<lutDimens {
                    let index = (i * lutDimens * lutDimens) + (j * lutDimens) + k
                    lutip[index * 4] = Float(dataip![index * 4]) / 255.0  // Red channel
                    lutip[index * 4 + 1] = Float(dataip![index * 4 + 1]) / 255.0  // Green channel
                    lutip[index * 4 + 2] = Float(dataip![index * 4 + 2]) / 255.0  // Blue channel
                    lutip[index * 4 + 3] = 1.0  // Alpha channel
                }
            }
        }

        // Convert the lut array to NSData
        let lutDataip = NSData(bytes: lutip, length: lutip.count * MemoryLayout<Float>.size)
        print("=== \(lutip.count) and  \(lutDataip.count) ====")
        /////////////////// OTHER PROCESSING
        ///
        let data1 = Data(referencing: lutData)
        let data2 = Data(referencing: lutDataip)
        
        // Convert the Data objects to arrays of Float values
        var lutArray1 = [Float](repeating: 0.0, count: data1.count / MemoryLayout<Float>.size)
        var lutArray2 = [Float](repeating: 0.0, count: data2.count / MemoryLayout<Float>.size)
        
        // Convert the Data objects to arrays of Float values
        data1.withUnsafeBytes { (rawBufferPointer: UnsafeRawBufferPointer) -> Void in
            let floatBufferPointer = rawBufferPointer.bindMemory(to: Float.self)
            let bufferPointer = UnsafeBufferPointer(start: floatBufferPointer.baseAddress, count: floatBufferPointer.count)
            lutArray1 = Array(bufferPointer)
        }

        data2.withUnsafeBytes { (rawBufferPointer: UnsafeRawBufferPointer) -> Void in
            let floatBufferPointer = rawBufferPointer.bindMemory(to: Float.self)
            let bufferPointer = UnsafeBufferPointer(start: floatBufferPointer.baseAddress, count: floatBufferPointer.count)
            lutArray2 = Array(bufferPointer)
        }

        // Perform color transfer by applying the values of LUT 1 onto LUT 2
        var transferredLutArray: [Float] = []
        let count = min(lutArray1.count, lutArray2.count)
        
        let s = get_mean_and_std(lutData: lutData)
        let t = get_mean_and_std(lutData: lutDataip)
        let s_mean = s.0
        let s_std = s.1
        let t_mean = t.0
        let t_std = t.1
        
        print("=== \(s) and \(s.0) and count = \(count)")

        for i in 0..<count {
            transferredLutArray.append(lutArray1[i])
        }
        
        var lutop = [Float](repeating: 0, count: lutDimens * lutDimens * lutDimens * 4)

        // Extract the color data from the image
        guard let imageDataop = cgImageip.dataProvider?.data else {
            print("Failed to get image data")
            return
        }

        let dataop = CFDataGetBytePtr(imageDataop)
        
        // Populate the LUT with color values
        for i in 0..<lutDimens {
            for j in 0..<lutDimens {
                for k in 0..<lutDimens {
                    let index = (i * lutDimens * lutDimens) + (j * lutDimens) + k
                    lutop[index * 4] = (((Float(dataop![index * 4]) / 255.0)-s_mean[0])*(t_std[0]/s_std[0]))+t_mean[0]  // Red channel
                    lutop[index * 4 + 1] = (((Float(dataop![index * 4 + 1]) / 255.0)-s_mean[1])*(t_std[1]/s_std[1]))+t_mean[1]  // Green channel
                    lutop[index * 4 + 2] = (((Float(dataop![index * 4 + 2]) / 255.0)-s_mean[2])*(t_std[2]/s_std[2]))+t_mean[2]  // Blue channel
                    lutop[index * 4 + 3] = 1.0  // Alpha channel
                }
            }
        }

        // Convert the lut array to NSData
         let lutDataop = NSData(bytes: lutop, length: lutop.count * MemoryLayout<Float>.size)
        print("=== \(lutop.count) and  \(lutDataop.count) ====")

        // Convert the transferred Float array back to Data object
        let transferredLutData = Data(buffer: UnsafeBufferPointer(start: &transferredLutArray, count: transferredLutArray.count))
        
        let transferredLutNSData = NSData(data: transferredLutData)
        
//        // Create a CIImage from the CGImage
//        let inputImage = CIImage(image: selectedImages[1])

        // Create a CIFilter for CIColorCube
        let colorCubeFilter = CIFilter(name: "CIColorCube")!
        colorCubeFilter.setValue(inputImage, forKey: kCIInputImageKey)
        colorCubeFilter.setValue(lutDataop, forKey: "inputCubeData")
        colorCubeFilter.setValue(lutDimens, forKey: "inputCubeDimension")

        // Apply the colorCubeFilter to get the output CIImage
        guard let outputImage = colorCubeFilter.outputImage else {
            print("Failed to get outputImage from colorCubeFilter")
            return
        }

        // Create a CIContext for rendering the output CIImage
        let ciContext = CIContext(options: nil)

        // Render the output CIImage to a CGImage
        guard let outputCGImage = ciContext.createCGImage(outputImage, from: outputImage.extent) else {
            print("Failed to create CGImage from outputImage")
            return
        }

        // Convert the CGImage to a UIImage
        let outputUIImage = UIImage(cgImage: outputCGImage)

        // You can now use the outputUIImage as needed, such as displaying it in an image view or saving it to a file.

        // Display or save the extracted LUT channels image as needed
        opImgView.image = outputUIImage
    }
    
    func reinhardLutColortransfer() {
        let sourceImage = selectedImages[0]
        let targetImage = selectedImages[1]

        // Get the CGImages from the UIImages
        guard let sourceCGImage = sourceImage.cgImage, let targetCGImage = targetImage.cgImage else {
            print("Failed to get CGImage from image")
            return
        }

        // Get the size of the images
        let width = sourceCGImage.width
        let height = sourceCGImage.height

        // Create LUTs for source and target images
        let lutDimens = 64
        var sourceLUT = [Float](repeating: 0, count: lutDimens * lutDimens * lutDimens * 4)
        var targetLUT = [Float](repeating: 0, count: lutDimens * lutDimens * lutDimens * 4)

        // Extract color data from the source and target images
        guard let sourceImageData = sourceCGImage.dataProvider?.data, let targetImageData = targetCGImage.dataProvider?.data else {
            print("Failed to get image data")
            return
        }

        let sourceData = CFDataGetBytePtr(sourceImageData)
        let targetData = CFDataGetBytePtr(targetImageData)

        // Populate the source and target LUTs with color values
        for i in 0..<lutDimens {
            for j in 0..<lutDimens {
                for k in 0..<lutDimens {
                    let index = (i * lutDimens * lutDimens) + (j * lutDimens) + k
                    sourceLUT[index * 4] = Float(sourceData![index * 4]) / 255.0  // Red channel
                    sourceLUT[index * 4 + 1] = Float(sourceData![index * 4 + 1]) / 255.0  // Green channel
                    sourceLUT[index * 4 + 2] = Float(sourceData![index * 4 + 2]) / 255.0  // Blue channel
                    sourceLUT[index * 4 + 3] = 1.0  // Alpha channel

                    targetLUT[index * 4] = Float(targetData![index * 4]) / 255.0  // Red channel
                    targetLUT[index * 4 + 1] = Float(targetData![index * 4 + 1]) / 255.0  // Green channel
                    targetLUT[index * 4 + 2] = Float(targetData![index * 4 + 2]) / 255.0  // Blue channel
                    targetLUT[index * 4 + 3] = 1.0  // Alpha channel
                }
            }
        }

        // Convert the LUTs to NSData
        let sourceLUTData = NSData(bytes: sourceLUT, length: sourceLUT.count * MemoryLayout<Float>.size)
        let targetLUTData = NSData(bytes: targetLUT, length: targetLUT.count * MemoryLayout<Float>.size)

        // Perform Reinhard color transfer
        let sourceCGImageWithLUT = sourceCGImage.applyingReinhardColorTransfer(withSourceLUTData: sourceLUTData, targetLUTData: targetLUTData, lutDimension: lutDimens)

        // Convert the resulting CGImage to UIImage
        let resultImage = UIImage(cgImage: sourceCGImageWithLUT!)

        // Update the UI with the resulting image
        opImgView.image = resultImage

    }
    
    func lutColorTransfer() {
        // Load the image from a UIImage or a file URL
        let image = selectedImages[0]

        // Get the CGImage from the UIImage
        guard let cgImage = image.cgImage else {
            print("Failed to get CGImage from image")
            return
        }

        // Get the size of the image
        let width = cgImage.width
        let height = cgImage.height

        // Create an empty array to store the LUT
        
        let lutDimens =  Int(valueSlider.value)// Int(inputLbl.text!)!
        btn4.setTitle("\(lutDimens)", for: .normal)
        var lut = [Float](repeating: 0, count: lutDimens * lutDimens * lutDimens * 4)

        // Extract the color data from the image
        guard let imageData = cgImage.dataProvider?.data else {
            print("Failed to get image data")
            return
        }

        let data = CFDataGetBytePtr(imageData)

        // Populate the LUT with color values
        for i in 0..<lutDimens {
            for j in 0..<lutDimens {
                for k in 0..<lutDimens {
                    let index = (i * lutDimens * lutDimens) + (j * lutDimens) + k
                    lut[index * 4] = Float(data![index * 4]) / 255.0  // Red channel
                    lut[index * 4 + 1] = Float(data![index * 4 + 1]) / 255.0  // Green channel
                    lut[index * 4 + 2] = Float(data![index * 4 + 2]) / 255.0  // Blue channel
                    lut[index * 4 + 3] = 1.0  // Alpha channel
                }
            }
        }

        // Convert the lut array to NSData
        let lutData = NSData(bytes: lut, length: lut.count * MemoryLayout<Float>.size)


        // Create a CIImage from the CGImage
        let inputImage = CIImage(image: selectedImages[1])

        // Create a CIFilter for CIColorCube
        let colorCubeFilter = CIFilter(name: "CIColorCube")!
        colorCubeFilter.setValue(inputImage, forKey: kCIInputImageKey)
        colorCubeFilter.setValue(lutData, forKey: "inputCubeData")
        colorCubeFilter.setValue(lutDimens, forKey: "inputCubeDimension")

        // Apply the colorCubeFilter to get the output CIImage
        guard let outputImage = colorCubeFilter.outputImage else {
            print("Failed to get outputImage from colorCubeFilter")
            return
        }

        // Create a CIContext for rendering the output CIImage
        let ciContext = CIContext(options: nil)

        // Render the output CIImage to a CGImage
        guard let outputCGImage = ciContext.createCGImage(outputImage, from: outputImage.extent) else {
            print("Failed to create CGImage from outputImage")
            return
        }

        // Convert the CGImage to a UIImage
        let outputUIImage = UIImage(cgImage: outputCGImage)

        // You can now use the outputUIImage as needed, such as displaying it in an image view or saving it to a file.

        // Display or save the extracted LUT channels image as needed
        opImgView.image = outputUIImage
    }
    
    func colorTransfer() {
        print(selectedImages)
        
        imgView.image = selectedImages[0]
        img3view.image =  selectedImages[1]

        // Load source image
        let sourceImage = imgView.image!

        // Convert source image to CIImage
        let sourceCIImage = CIImage(image: sourceImage)!

        // Load target image
        let targetImage = img3view.image!

        // Convert target image to CIImage
        let targetCIImage = CIImage(image: targetImage)!

        // Create a CIContext for rendering
        let context = CIContext(options: nil)

        // Render the source CIImage to a CGImage
        let sourceCGImage = context.createCGImage(sourceCIImage, from: sourceCIImage.extent)!

        // Get pixel data from the source CGImage
        let sourceDataProvider = CGDataProvider(data: sourceCGImage.dataProvider!.data!)!
        let sourceData = sourceDataProvider.data!
        let sourcePixels = CFDataGetBytePtr(sourceData)
        let sourceBytesPerRow = sourceCGImage.bytesPerRow
        let sourceWidth = sourceCGImage.width
        let sourceHeight = sourceCGImage.height

        // Extract RGB values from source image at a specific pixel location
        let pixelIndex = (0 * sourceBytesPerRow) + (0 * 4) // Assumes 32-bit RGBA image format
        let redComponent = CGFloat(sourcePixels![pixelIndex]) / 255.0
        let greenComponent = CGFloat(sourcePixels![pixelIndex + 1]) / 255.0
        let blueComponent = CGFloat(sourcePixels![pixelIndex + 2]) / 255.0

        // Create a color matrix filter
        let colorMatrix = CIFilter(name: "CIColorMatrix")!

        // Set input parameters for color matrix filter
        colorMatrix.setValue(CIVector(x: 1, y: 0, z: 0, w: 0), forKey: "inputRVector")
        colorMatrix.setValue(CIVector(x: 0, y: 1, z: 0, w: 0), forKey: "inputGVector")
        colorMatrix.setValue(CIVector(x: 0, y: 0, z: 1, w: 0), forKey: "inputBVector")
        colorMatrix.setValue(CIVector(x: 0, y: 0, z: 0, w: 1), forKey: "inputAVector")
        colorMatrix.setValue(CIVector(x: redComponent, y: greenComponent, z: blueComponent, w: 0), forKey: "inputBiasVector")
        colorMatrix.setValue(targetCIImage, forKey: kCIInputImageKey)

        // Apply the color matrix filter to the target image
        let outputCIImage = colorMatrix.outputImage!

        // Render the output CIImage to a CGImage
        let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent)!

        // Convert the CGImage to a UIImage
        let outputUIImage = UIImage(cgImage: outputCGImage)

        // Display the output image
        // You can set the outputUIImage to a UIImageView or display it in any other way in your app



        // Display the output image
        opImgView.image = outputUIImage
    }
    
}


