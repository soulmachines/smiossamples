//
//  ViewController.swift
//  SMSwiftSample
//

import UIKit
import SMDarwin
import SwiftJWT
import MessageUI
import AVKit

//Claim for SwiftJWT
struct SMClaim: Claims {
    var smControl: String?
    var smControlViaBrowser: Bool
    var nbf: Double
    var exp: Double
    var iat: Double
    var iss: String
    
    enum CodingKeys: String, CodingKey {
        case smControl = "sm-control"
        case smControlViaBrowser = "sm-control-via-browser"
        case nbf
        case exp
        case iat
        case iss
    }
}

enum CameraViewDirection {
    case Left
    case Center
    case Right
}

class ViewController: UIViewController {
    @IBOutlet private weak var connectButton: UIButton?
    @IBOutlet private weak var muteButton: UIButton?
    @IBOutlet private weak var cameraControlView: UIView?
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView?
    
    @IBOutlet private weak var localVideoView: UIView?
    @IBOutlet private weak var remoteVideoView: UIView?
    
    private var isMuted = false
    private var scene: Scene?
    
    private let filename = "SMSwiftSample_Log"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.muteButton?.isHidden = true
        self.cameraControlView?.isHidden = true
        self.connectButton?.tintColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        let _ = LoggingCenter.loggingCenter.set(logType: .File, filename: filename)
        self.scene = SceneFactory.create(userMediaOptions: .MicrophoneAndCamera)
        
        //Note that the SDK will request permissions normally as the connection occurs, if microphone isn't granted the persona can still be interacted with using the `conversationSend` Scene message.
        self.requestPermissions()
        
        if let remoteView = self.remoteVideoView {
            self.scene?.set(remoteView: remoteView, localView: self.localVideoView)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let displayedSettingsKey = "DisplayedSettings"
        let displayedFirstRunSettings = UserDefaults.standard.bool(forKey: displayedSettingsKey)
        if false == displayedFirstRunSettings, let settingsViewController = self.storyboard?.instantiateViewController(identifier: "SettingsViewController") {
            self.present(settingsViewController, animated: true, completion: {
                UserDefaults.standard.set(true, forKey: displayedSettingsKey)
            })
        }
    }
    
    private func disconnect() {
        self.scene?.disconnect()
        self.connectButton?.tintColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        self.muteButton?.isHidden = true
        self.cameraControlView?.isHidden = true
    }
    
    private func connect() {
        var jwt = ""
        let serverUrl = UserDefaults.standard.string(forKey: ConfigId.ServerUrl.rawValue) ?? ""
        
        if self.isMuted {
            self.toggleMute()
        }
        
        if true == UserDefaults.standard.bool(forKey: ConfigId.UseJWT.rawValue) {
            jwt = UserDefaults.standard.string(forKey: ConfigId.JWT.rawValue) ?? ""
        } else {
            let keyName = UserDefaults.standard.string(forKey: ConfigId.KeyName.rawValue) ?? ""
            let privateKey = UserDefaults.standard.string(forKey: ConfigId.PrivateKey.rawValue) ?? ""
            let useOrchestration = UserDefaults.standard.bool(forKey: ConfigId.EnableOrchestration.rawValue)
            let orchestrationServer = UserDefaults.standard.string(forKey: ConfigId.OrchestrationUrl.rawValue)
            let timestamp = Date().timeIntervalSince1970
            //As we are using the default RetryOptions, 350 seconds should cover the internal 1 minute timeout per connection, and the 5 second delay in between connection attempts.
            let expiry = Date().addingTimeInterval(350).timeIntervalSince1970
            
            let claims = SMClaim(smControl: (useOrchestration) ? orchestrationServer : "", smControlViaBrowser: useOrchestration, nbf: timestamp, exp: expiry, iat: timestamp, iss: keyName)
            var jwtObject = JWT(claims: claims)
            
            guard let privateKeyData = privateKey.data(using: .utf8) else {
                debugPrint("Unable to parse private key to data.")
                return
            }
            
            let jwtSigner = JWTSigner.hs256(key: privateKeyData)
            do {
                jwt = try jwtObject.sign(using: jwtSigner)
            } catch(let error) {
                debugPrint("Encountered an error trying to sign jwt: \(error.localizedDescription)")
            }
        }
        
        self.scene?.connect(url: serverUrl, userText: nil, accessToken: jwt, retryOptions: RetryOptions()).subscribe(completion: { completion in
            DispatchQueue.main.async {
                self.connectButton?.isEnabled = true
                self.activityIndicator?.stopAnimating()
                
                if let connectError = completion.error {
                    debugPrint("Error connecting to scene: \(connectError.debugDescription)")
                    let message = """
                    \(connectError.userInfo[NSDebugDescriptionErrorKey] ?? "")
                    Error stack: \(connectError.getStack() ?? "No further errors encountered.")
                    """
                    self.displayAlert(title: "Connection Error", message: message)
                    return
                }
                
                if let _ = completion.result as? SessionInfo {
                    debugPrint("Successful scene connection.")
                    self.muteButton?.isHidden = false
                    self.cameraControlView?.isHidden = false
                    self.connectButton?.tintColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
                }
            }
        })
    }
    
    @IBAction private func didToggleConnect() {
        if self.scene?.getSessionInfo() != nil {
            self.disconnect()
        } else {
            if AVCaptureDevice.authorizationStatus(for: .audio) != .authorized {
                self.displayAlert(title: "Missing Microphone Permission", message: "This App requires microphone access to connect. Please enable the Microphone permission in the Settings App.")
                return
            }
            
            self.connectButton?.isEnabled = false
            self.activityIndicator?.startAnimating()
            self.connect()
        }
    }

    @IBAction private func didToggleMute() {
        self.toggleMute()
    }
    
    @IBAction private func viewFromLeft() {
        self.changeCameraView(toDirection: .Left)
    }
    
    @IBAction private func viewFromRight() {
        self.changeCameraView(toDirection: .Right)
    }
    
    @IBAction private func viewFromCenter() {
        self.changeCameraView(toDirection: .Center)
    }
    
    private func changeCameraView(toDirection direction: CameraViewDirection) {
        //
        if let persona = self.scene?.getPersonas().first {
            var scalar: Float = 0
            
            switch direction {
            case .Left:
                scalar = -1
                break
            case .Right:
                scalar = 1
                break
            default:
                break
            }
            
            let orbitDegX: Float = scalar == 0 ? 0 : 10 * scalar
            let orbitDegY: Float = scalar == 0 ? 0 : 10
            let panDeg: Float = scalar == 0 ? 0 : 2 * scalar
            
            let animation = NamedCameraAnimationParam(cameraName: "CloseUp", time: 1, orbitDegX: orbitDegX, orbitDegY: orbitDegY, panDeg: panDeg, tiltDeg: 0)
            
            DispatchQueue.global(qos: .userInitiated).async {
                persona.animateToNamedCameraWithOrbitPan(param: animation).subscribe(completion: { completion in
                    if let error = completion.error {
                        debugPrint("Encountered error animating camera: \(error.debugDescription)")
                    }
                })
            }
        }
    }
    
    private func toggleMute() {
        let shouldMute = !self.isMuted
        
        if shouldMute {
            self.scene?.getSpeechRecognizer().stopRecognize().subscribe(completion: { completion in
                if let recognizeError = completion.error {
                    debugPrint("Received error stopping speech recognizer: \(recognizeError.debugDescription)")
                }
                
                if let successMessage = completion.result {
                    debugPrint("Successfully stopped speech recognizer. \(successMessage)")
                    self.isMuted = shouldMute
                    self.set(muteImage: UIImage(systemName: "mic.slash.fill"))
                }
            })
        } else {
            self.scene?.getSpeechRecognizer().startRecognize(audioSourceType: .Processed).subscribe(completion: { completion in
                if let recognizeError = completion.error {
                    debugPrint("Received error starting speech recognizer: \(recognizeError.debugDescription)")
                }
                
                if let successMessage = completion.result {
                    debugPrint("Successfully started speech recognizer. \(successMessage)")
                    self.isMuted = shouldMute
                    self.set(muteImage: UIImage(systemName: "mic.fill"))
                }
            })
        }
    }
    
    private func set(muteImage: UIImage?) {
        DispatchQueue.main.async {
            self.muteButton?.setImage(muteImage, for: .normal)
        }
    }
    
    private func requestPermissions() {
        if AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                debugPrint("Video authorization granted: \(granted.description)")
            })
        }
        if AVCaptureDevice.authorizationStatus(for: .audio) == .notDetermined {
            AVCaptureDevice.requestAccess(for: .audio, completionHandler: { granted in
                debugPrint("Audio authorization granted: \(granted.description)")
            })
        }
    }
    
    @IBAction private func sendLogs() {
        guard true == MFMailComposeViewController.canSendMail() else {
            self.displayAlert(title: "Email Error", message: "Unable to send mail from the current device.")
            return
        }
        
        guard let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first, let logData = try? Data.init(contentsOf: path.appendingPathComponent(filename)) else {
            debugPrint("Unable to load log data from file.")
            return
        }
        
        let mailView = MFMailComposeViewController()
        mailView.mailComposeDelegate = self
        mailView.setSubject(filename)
        mailView.addAttachmentData(logData, mimeType: "text/*", fileName: filename)
        var validRtcLog = true
        var logIndex = 0
        
        //Attaches webrtc logs.
        while validRtcLog {
            let rtcLogName = "webrtc_log_\(logIndex)"
            if let rtcLogData = try? Data.init(contentsOf: path.appendingPathComponent("\(filename)_RTCLog/\(rtcLogName)")) {
                mailView.addAttachmentData(rtcLogData, mimeType: "text/*", fileName: rtcLogName)
                logIndex += 1
            } else {
                validRtcLog = false
            }
        }
        
        self.present(mailView, animated: true)
    }
    
    private func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
}

extension ViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let _ = error {
            debugPrint("Encountered an error sending mail: \(error.debugDescription)")
        }
        
        if result == .failed {
            self.displayAlert(title: "Email Error", message: "Message failed to send.")
        }
        
        controller.dismiss(animated: true)
    }
}
