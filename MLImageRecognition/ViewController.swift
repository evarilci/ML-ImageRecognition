//
//  ViewController.swift
//  MLImageRecognition
//
//  Created by Eymen Varilci on 19.03.2022.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController {
    
    var imageView = UIImageView()
    var label = UILabel()
    var button = UIButton()
    var choosenImage = CIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        label.text = "select an image to identify"
        label.sizeToFit()
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 3
        label.backgroundColor = .darkGray.withAlphaComponent(0.8)
        label.layer.cornerRadius = 25
        label.clipsToBounds = true
        imageView.backgroundColor = .white.withAlphaComponent(0.6)
        imageView.layer.cornerRadius = 25
        imageView.clipsToBounds = true
        imageView.sizeToFit()
        button.setTitle("Choose Pic", for: UIControl.State.normal)
        button.setTitleColor(.link, for: UIControl.State.normal)
        button.backgroundColor = .darkGray.withAlphaComponent(0.7)
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(choosePic), for: UIControl.Event.touchUpInside)
        
        view.addSubview(imageView)
        view.addSubview(label)
        view.addSubview(button)
        
        addConstraints()
    }
    
    @objc func choosePic(){
        
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        present(picker, animated: true, completion: nil)
        
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        if let ciImage = CIImage(image: imageView.image!) {
            choosenImage = ciImage
        }
        recognizeImage(image: choosenImage)
        
    }
    
    func recognizeImage(image: CIImage) {
        
        // 1 request
        // 2 handler
        label.text! = "Identifying..."
        
        if let model = try? VNCoreMLModel(for: MobileNetV2().model) {
            let request = VNCoreMLRequest(model: model) { vnrequest, error in
                if let results = vnrequest.results as? [VNClassificationObservation]{
                    if results.count > 0 {
                        let topResult = results.first
                        DispatchQueue.main.async {
                            let confidenceLevel = (topResult?.confidence ?? 0) * 100
                            let rounded = Int(confidenceLevel * 100) / 100
                            self.label.text = "by \(rounded)% chance it's \(topResult!.identifier)"
                        }
                    }
                }
            }
            let handler = VNImageRequestHandler(ciImage: image)
            
            DispatchQueue.global(qos: .userInteractive).async {
                
                do{
                    try handler.perform([request])
                } catch{
                }
            }
        }
    }
    
    func addConstraints(){
        imageView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
            
            
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
            imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 4/5),
            imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            label.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -5),
            label.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
            label.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            label.heightAnchor.constraint(equalToConstant: 50),
            button.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            button.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
            button.widthAnchor.constraint(equalToConstant: 50),
            button.heightAnchor.constraint(equalToConstant: 50),
            // button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            button.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 25),
            button.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -10),
            
        ])
        
        
    }
    
}

extension ViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
}

