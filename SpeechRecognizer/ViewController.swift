//
//  ViewController.swift
//  SpeechRecognizer
//
//  Created by adi on 26.11.16.
//  Copyright © 2016 AmikhaielHacker. All rights reserved.
//
import AVFoundation
import UIKit
import Speech

class ViewController: UIViewController, SFSpeechRecognizerDelegate {
    @IBOutlet weak var TextViewEmpty: UITextView!
    @IBOutlet weak var SpeakOutlet: UIButton!
    private let speech = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    private var RequestRecognition: SFSpeechAudioBufferRecognitionRequest?
    private var TaskRecognition: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    override func viewDidLoad() {
        super.viewDidLoad()
        //Asking for authorizing the microfone usage.
        speech?.delegate = self
        SFSpeechRecognizer.requestAuthorization {(authStatus) in
            var isbEnabled = false
            
            switch authStatus {
            case .authorized:
                isbEnabled = true
            case .denied:
                isbEnabled = false
                self.TextViewEmpty.text = "You denied the speech recognizer."
            default:
                break
            }
            OperationQueue.main.addOperation {
                self.SpeakOutlet.isEnabled = isbEnabled
            }
        }
        
        SpeakOutlet.isEnabled = false
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    @IBAction func SpeakerButton(_ sender: AnyObject) {
        if audioEngine.isRunning {
            audioEngine.stop()
            RequestRecognition?.endAudio()
            SpeakOutlet.isEnabled = false
            SpeakOutlet.setTitle("Speak", for: .normal)
        }
    }
    
    func startRecording()  {
        if TaskRecognition != nil {
            TaskRecognition?.cancel()
            TaskRecognition = nil
        }
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        RequestRecognition = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode else {
            fatalError("Audio engine has no input node")
        }
        
        guard let RequestRecognition = RequestRecognition else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        RequestRecognition.shouldReportPartialResults = true
        
        TaskRecognition = speech?.recognitionTask(with: RequestRecognition, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil {
                
                self.TextViewEmpty.text = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.RequestRecognition = nil
                self.TaskRecognition = nil
                
                self.SpeakOutlet.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.RequestRecognition?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
        TextViewEmpty.text = "Say something, I'm listening!"
    }
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            SpeakOutlet.isEnabled = true
        } else {
            SpeakOutlet.isEnabled = false
        }
    }

}



































