//
//  CameraCaptureVC.swift
//  breakpoint
//
//  Created by 김영석 on 24/10/2018.
//  Copyright © 2018 Caleb Stultz. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase


class CameraCaptureVC: UIViewController, AVCapturePhotoCaptureDelegate{

    
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var captureImageView: UIImageView!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var switchCameraBtn: UIButton!
    @IBOutlet weak var captureBtn: UIButton!
    @IBOutlet weak var cameraImageSaveBtn: UIButton!
    

    
    let storage = Storage.storage()
    
    
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!

    
    // imageData
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.captureSession.stopRunning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
      
        
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .medium
        
        guard let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
            else {
                print("Unable to access back camera!")
                return
            }
        
    
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
        
            stillImageOutput = AVCapturePhotoOutput()
            
            
            if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(stillImageOutput)
                setupLivePreview()
                
            }
        }
            
        catch let error  {
            print("Error Unable to initialize back camera:  \(error.localizedDescription)")
        }
        
        
        }
    
    
    @IBAction func didTakePhoto(_ sender: Any) {
        
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        
      
        
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                             kCVPixelBufferWidthKey as String: 100,
                             kCVPixelBufferHeightKey as String: 100]
        settings.previewPhotoFormat = previewFormat
        
        stillImageOutput.capturePhoto(with: settings, delegate: self)
        
        
        
        
        
        //<AVCapturePhotoOutput: 0x281604060>
        // 파일을 어떻게 생성 할 것 인가
        // 불러온 사진을 임시 저장 항목에 넣어줘야 함
        
    }

  
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
       
        let uid = (Auth.auth().currentUser?.uid)!
        guard let imageData = photo.fileDataRepresentation()
            else { return }

        var image = UIImage(data: imageData)
        
        captureImageView.image = image
        print(image)
        
        ///// image를 띄우는 것 까지의 과정
        

        image = rotateImage(image: image!)
    }
    

    



    func setupLivePreview() {
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        videoPreviewLayer.videoGravity = .resizeAspect
        videoPreviewLayer.connection?.videoOrientation = .portrait
        previewView.layer.addSublayer(videoPreviewLayer)
        
        
        DispatchQueue.global(qos: .userInitiated).async { //[weak self] in
            self.captureSession.startRunning()
            
            DispatchQueue.main.async {
                self.videoPreviewLayer.frame = self.previewView.bounds
            }
            
        }
        
    }
    
    
    @IBAction func cancelBtnWasPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
  
    
    @IBAction func switchCameraBtnWasPressed(_ sender: Any) {
     
        
         // back - front
            let currentCameraInput: AVCaptureInput = captureSession.inputs[0]
            captureSession.removeInput(currentCameraInput)
            var newCamera: AVCaptureDevice
            newCamera = AVCaptureDevice.default(for: AVMediaType.video)!
            
            if (currentCameraInput as! AVCaptureDeviceInput).device.position == .back {
                UIView.transition(with: self.previewView, duration: 0.5, options: .transitionFlipFromLeft, animations: {
                    newCamera = self.cameraWithPosition(.front)!
                }, completion: nil)
            } else {
                UIView.transition(with: self.previewView, duration: 0.5, options: .transitionFlipFromRight, animations: {
                    newCamera = self.cameraWithPosition(.back)!
                }, completion: nil)
            }
            do {
                try self.captureSession?.addInput(AVCaptureDeviceInput(device: newCamera))
            }
            catch {
                print("error: \(error.localizedDescription)")
            }
        
    }
    
    func cameraWithPosition(_ position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let deviceDescoverySession = AVCaptureDevice.DiscoverySession.init(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        
        for device in deviceDescoverySession.devices {
            if device.position == position {
                return device
            }
        }
        return nil
    }
    
    
    
    @IBAction func cameraImageSaveBtnWasPressed(_ sender: Any) {
        // 기본적으로 defaultimage가 셋팅 되어있으니 그냥 해도 된다
        
        let uid = (Auth.auth().currentUser?.uid)!
        var imageLoad = captureImageView.image
        imageLoad = rotateImage(image: imageLoad!)

        if let data = UIImagePNGRepresentation(imageLoad!) {
            
            // data = 이미지 파일로 변환함
            
            
            
            let storageRef = storage.reference()
            let captureImage = storageRef.child("\((Auth.auth().currentUser?.email)!)_capture.png")
            
            let captureImageRef = storageRef.child("images/\((Auth.auth().currentUser?.email)!)_capture.png")
            
            
            // Upload the file to the path "images/rivers.jpg"
            let uploadTask = captureImageRef.putData(data, metadata: nil) { (metadata, error) in
                guard let metadata = metadata else {
                    // Uh-oh, an error occurred!
                    return
                }
                // Metadata contains file metadata such as size, content-type.
                let size = metadata.size
                // You can also access to download URL after upload.
                captureImageRef.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        // Uh-oh, an error occurred!
                        return
                    }
                }
                DataService.instance.cameraUploadImage(forUID: uid, cameraImage: captureImageRef.fullPath)
             
                self.dismiss(animated: true, completion: nil)
            }
            
          
            
            
        }
        
        
    }
    
    func rotateImage(image: UIImage) -> UIImage {
        
        if (image.imageOrientation == UIImageOrientation.up ) {
            return image
        }
        
        UIGraphicsBeginImageContext(image.size)
        
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
        let copy = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return copy!
    }
}



