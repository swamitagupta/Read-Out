//
//  ViewController.swift
//  Read Out
//
//  Created by Swamita on 18/03/21.
//

import UIKit
import Vision
import AVFoundation

class ViewController: UIViewController, AVSpeechSynthesizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    
    let imagePicker = UIImagePickerController()
    let synthesizer = AVSpeechSynthesizer()
    var request = VNRecognizeTextRequest(completionHandler: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        synthesizer.delegate = self
        
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false

    }

    @IBAction func cameraTapped(_ sender: Any) {
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func speakerTapped(_ sender: Any) {
        let utterance = AVSpeechUtterance(string: textView.text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        synthesizer.speak(utterance)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            else { fatalError("Failed to load image!") }
        imageView.image = image
        imagePicker.dismiss(animated: true, completion: nil)
        self.textView.text = ""
        recognizeText(image: image)
    }
    
    private func recognizeText(image: UIImage) {
        
        var imageText = ""
    
        request = VNRecognizeTextRequest(completionHandler: { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation]
            else {
                fatalError("Invalid Observation")
            }
            for observation in observations{
                guard let topCandidate = observation.topCandidates(1).first
                else {print("No candidate")
                    continue
                }
                imageText += " \(topCandidate.string)"
                DispatchQueue.main.async {
                    self.textView.text = imageText
                }
            }
        })
        request.customWords = ["custom"]
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["en_US"]
        request.usesLanguageCorrection = true
        
        let requests = [request]
        
        DispatchQueue.global(qos: .userInitiated).async {
            guard let img = image.cgImage else {
                fatalError("Cant scan")
            }
            let handle = VNImageRequestHandler(cgImage: img, options: [:])
            try? handle.perform(requests)
        }
    }
}

