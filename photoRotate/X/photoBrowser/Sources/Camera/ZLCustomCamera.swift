//
//  ZLCustomCamera.swift
//  ZLPhotoBrowser
//
//  Created by long on 2020/8/11.
//
//  Copyright (c) 2020 Long Zhang <longitachi@163.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit
import AVFoundation
import CoreMotion



enum CustomCameraOpt{
    case dft
    case result
}

//  The anatomy of an Audio Unit

public
class ZLCustomCamera: UIViewController, CAAnimationDelegate {

    struct Layout {
        
        static let bottomViewH: CGFloat = 150
        
        static let largeCircleRadius: CGFloat = 80
        
        
        
        static let largeCircleRecordScale: CGFloat = 1.2
        
        static let smallCircleRecordScale: CGFloat = 0.7
        
    }
    
    
    @objc public var takeDoneBlock: ( (UIImage?) -> Void )?
    
    lazy var tipsLabel: UILabel = {
        let h: CGFloat = 60
        let frm = CGRect(x: 0, y: 0, width: view.bounds.width, height: h)
        let bel = UILabel(frame: frm)
        bel.center = CGPoint(x: UI.std.width * 0.5, y: UI.std.height * 0.5)
        bel.font = UIFont.regular(ofSize: 16)
        bel.textColor = .white
        bel.textAlignment = .center
        bel.alpha = 0
        
        bel.numberOfLines = 2
       
        bel.text = tip_d
        return bel
    }()
    
    var hideTipsTimer: Timer?
    
    lazy var bottomView = UIView()
    
    lazy var largeCircleView: UIImageView = {
        let img = UIImageView(image: UIImage(named: "my_p_photo_it"))
        img.isUserInteractionEnabled = true
        return img
    }()
    
    lazy var retakeBtn: UIButton = {
        
        var insets = UIEdgeInsets.zero
        if #available(iOS 11.0, *) {
            insets = self.view.safeAreaInsets
        }
        
        let keBtn = UIButton(type: .custom)
        keBtn.isHidden = true
        keBtn.setTitle("重拍", for: .normal)
        keBtn.setTitleColor(UIColor.white, for: .normal)
        keBtn.titleLabel?.font = UIFont.regular(ofSize: 18)
        keBtn.addTarget(self, action: #selector(retakeBtnClick), for: .touchUpInside)
        keBtn.adjustsImageWhenHighlighted = false
        keBtn.zl_enlargeValidTouchArea(inset: 30)
        return keBtn
    }()
    
    lazy var upTitle: UILabel = {
        let l = UILabel()
        l.text = "拍照结果"
        l.isHidden = true
        l.font = UIFont.regular(ofSize: 18)
        l.textColor = UIColor.white
        l.textAlignment = .center
        return l
    }()
    
    lazy var upBitch: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(rgb: 0x37393D)
        v.alpha = 0.6
        v.isHidden = true
        return v
    }()
    
    
    lazy var rotateBtn: UIButton = {
        let neBtn = UIButton(type: .custom)
        neBtn.setImage(UIImage(named: "camera_turn_around"), for: .normal)

        neBtn.isHidden = true
        return neBtn
    }()
    
    
    
    
    lazy var bottomBeach: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(rgb: 0x37393D)
        v.alpha = 0.6
        v.isHidden = true
        return v
    }()
    
    
    
    lazy var doneBtn: UIButton = {
        let neBtn = UIButton(type: .custom)
        neBtn.setImage(UIImage(named: "camera_done"), for: .normal)
        neBtn.addTarget(self, action: #selector(doneBtnClick), for: .touchUpInside)
        neBtn.isHidden = true
        neBtn.layer.masksToBounds = true
        neBtn.layer.cornerRadius = ZLLayout.bottomToolBtnCornerRadius
        return neBtn
    }()
    
    lazy var dismissBtn: UIButton = {
        let edge: CGFloat = 40
        let x = UI.std.width - 20 - edge
        let b = UIButton(frame: CGRect(x: x, y: 30, width: edge, height: edge))
        b.setImage(UIImage(named: "camera_woX"), for: .normal)
        b.addTarget(self, action: #selector(dismissBtnClick), for: .touchUpInside)
        b.adjustsImageWhenHighlighted = false
        b.zl_enlargeValidTouchArea(inset: 30)
        return b
    }()

    
    
    lazy var bg: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black
        v.isHidden = true
        return v
    }()
    
    
    lazy var takedImageView: UIImageView = {
        let takedImag = UIImageView()
        takedImag.backgroundColor = .black
        takedImag.isHidden = true
        takedImag.contentMode = .scaleAspectFit
       
        return takedImag
    }()
    
    var takedImage: UIImage?
    
    var motionManager: CMMotionManager?
    
    var orientation: AVCaptureVideoOrientation = .portrait
    
    let session = AVCaptureSession()
    
    var videoInput: AVCaptureDeviceInput?
    
    lazy var imageOutput = AVCapturePhotoOutput()
    
    lazy var movieFileOutput = AVCaptureMovieFileOutput()
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var recordVideoPlayerLayer: AVPlayerLayer?
    
    var cameraConfigureFinish = false
    
    var layoutOK = false
    
    var dragStart = false
    
    var viewDidAppearCount = 0
    
    var restartRecordAfterSwitchCamera = false
    
    var cacheVideoOrientation: AVCaptureVideoOrientation = .portrait
    
    var recordUrls = [URL]()
    
    
    var tip_d = "轻触拍照"
    
    
    var angleX: CGFloat = 0
    

    public override var prefersStatusBarHidden: Bool {
        return true
    }
    
    deinit {
        self.cleanTimer()
        if self.session.isRunning {
            self.session.stopRunning()
        }
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
    
    @objc public init() {
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        
        events()
        
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            return
        }
        self.setupCamera()
        self.observerDeviceMotion()
        self.addNotification()
        
        AVCaptureDevice.requestAccess(for: .video) { (videoGranted) in
            if videoGranted {
                if ZLPhotoConfiguration.default().allowRecordVideo {
                    AVCaptureDevice.requestAccess(for: .audio) { (audioGranted) in
                        if !audioGranted {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                self.showAlertAndDismissAfterDoneAction(message: String(format: localLanguageTextValue(.noMicrophoneAuthority), getAppName()))
                            }
                        }
                    }
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    self.showAlertAndDismissAfterDoneAction(message: String(format: localLanguageTextValue(.noCameraAuthority), getAppName()))
                })
            }
        }
        if ZLPhotoConfiguration.default().allowRecordVideo {
            try? AVAudioSession.sharedInstance().setCategory(.playAndRecord)
            try? AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        }
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            showAlertAndDismissAfterDoneAction(message: localLanguageTextValue(.cameraUnavailable))
        } else if !ZLPhotoConfiguration.default().allowTakePhoto, !ZLPhotoConfiguration.default().allowRecordVideo {
            #if DEBUG
            fatalError("参数配置错误")
            #else
            showAlertAndDismissAfterDoneAction(message: "相机参数配置错误")
            #endif
        } else if self.cameraConfigureFinish, self.viewDidAppearCount == 0 {
            self.showTipsLabel(animate: true)
            self.session.startRunning()
            self.setFocusCusor(point: self.view.center)
        }
        self.viewDidAppearCount += 1
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.motionManager?.stopDeviceMotionUpdates()
        self.motionManager = nil
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.session.stopRunning()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard !self.layoutOK else { return }
        self.layoutOK = true
        
        var insets = UIEdgeInsets.zero
        if #available(iOS 11.0, *) {
            insets = self.view.safeAreaInsets
        }
        let previewLayerY: CGFloat = deviceSafeAreaInsets().top > 0 ? 20 : 0
        self.previewLayer?.frame = CGRect(x: 0, y: previewLayerY, width: self.view.bounds.width, height: self.view.bounds.height)
        self.recordVideoPlayerLayer?.frame = self.view.bounds
        takedImageView.frame = view.bounds
        
        self.bottomView.frame = CGRect(x: 0, y: self.view.bounds.height-insets.bottom-ZLCustomCamera.Layout.bottomViewH-50, width: self.view.bounds.width, height: ZLCustomCamera.Layout.bottomViewH)
        let largeCircleH = ZLCustomCamera.Layout.largeCircleRadius
        self.largeCircleView.frame = CGRect(x: (self.view.bounds.width-largeCircleH)/2, y: (ZLCustomCamera.Layout.bottomViewH-largeCircleH)/2, width: largeCircleH, height: largeCircleH)

    }
    
    func setupUI() {
        self.view.backgroundColor = .black
        
        view.addSubs([bg, takedImageView, tipsLabel,
                      bottomView, dismissBtn])
    
        
        bg.snp.makeConstraints { (m) in
            m.edges.equalToSuperview()
        }
        
     
        self.largeCircleView.layer.masksToBounds = true
        self.largeCircleView.layer.cornerRadius = ZLCustomCamera.Layout.largeCircleRadius / 2
        bottomView.addSubview(self.largeCircleView)
        
        
        
        view.addSubs([upBitch, bottomBeach, retakeBtn,
                      doneBtn, upTitle, rotateBtn ])
        
        upBitch.snp.makeConstraints { (m) in
            m.leading.trailing.top.equalToSuperview()
            m.height.equalTo(80 + UI.std.origineY)
        }
        
        upTitle.snp.makeConstraints { (m) in
            m.centerX.equalToSuperview()
            m.bottom.equalTo(upBitch).offset(-15)
        }
        
        bottomBeach.snp.makeConstraints { (m) in
            m.leading.trailing.bottom.equalToSuperview()
            m.height.equalTo(120 + UI.std.bottomOffsetY)
        }
        let bottom: CGFloat = UI.std.bottomOffsetY + 55
        retakeBtn.snp.makeConstraints { (m) in
            m.leading.equalToSuperview().offset(50)
            m.bottom.equalToSuperview().offset(bottom.neg)
        }
        

        doneBtn.snp.makeConstraints { (m) in
            m.centerX.equalToSuperview()
            m.top.equalTo(bottomBeach).offset(10)
            m.size.equalTo(CGSize(width: 80, height: 80))
        }
        
        rotateBtn.snp.makeConstraints { (m) in
            m.trailing.equalToSuperview().offset(-50)
            m.top.equalTo(bottomBeach).offset(40)
            m.size.equalTo(CGSize(width: 25, height: 26))
        }
    }
    
    
    
    func events(){
        var takePictureTap: UITapGestureRecognizer?
        if ZLPhotoConfiguration.default().allowTakePhoto {
            takePictureTap = UITapGestureRecognizer(target: self, action: #selector(takePicture))
            self.largeCircleView.addGestureRecognizer(takePictureTap!)
        }
        
        
        let focusCursorTap = UITapGestureRecognizer(target: self, action: #selector(adjustFocusPoint))
        focusCursorTap.delegate = self
        self.view.addGestureRecognizer(focusCursorTap)
        
        
        rotateBtn.addTarget(self, action: #selector(rotateRhs), for: .touchUpInside ) 
        
    }
    
    
    
    
    func observerDeviceMotion() {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.observerDeviceMotion()
            }
            return
        }
        self.motionManager = CMMotionManager()
        self.motionManager?.deviceMotionUpdateInterval = 0.5
        
        if self.motionManager?.isDeviceMotionAvailable == true {
            self.motionManager?.startDeviceMotionUpdates(to: OperationQueue.main, withHandler: { (motion, error) in
                if let _ = motion {
                    self.handleDeviceMotion(motion!)
                }
            })
        } else {
            self.motionManager = nil
        }
    }
    
    func handleDeviceMotion(_ motion: CMDeviceMotion) {
        let x = motion.gravity.x
        let y = motion.gravity.y
        
        if abs(y) >= abs(x) {
            if y >= 0 {
                self.orientation = .portraitUpsideDown
            } else {
                self.orientation = .portrait
            }
        } else {
            if x >= 0 {
                self.orientation = .landscapeLeft
            } else {
                self.orientation = .landscapeRight
            }
        }
    }
    
    func setupCamera() {
        guard let backCamera = self.getCamera(position: .back) else { return }
        
        guard let input = try? AVCaptureDeviceInput(device: backCamera) else { return }
        // 相机画面输入流
        self.videoInput = input
        
        // 音频输入流
        var audioInput: AVCaptureDeviceInput?
        if ZLPhotoConfiguration.default().allowRecordVideo, let microphone = self.getMicrophone() {
            audioInput = try? AVCaptureDeviceInput(device: microphone)
        }
        
        let preset = ZLPhotoConfiguration.default().sessionPreset.avSessionPreset
        if self.session.canSetSessionPreset(preset) {
            self.session.sessionPreset = preset
        } else {
            self.session.sessionPreset = .hd1280x720
        }
        
        // 解决视频录制超过10s没有声音的bug
        self.movieFileOutput.movieFragmentInterval = .invalid
        
        // 将视频及音频输入流添加到session
        if let vi = self.videoInput, self.session.canAddInput(vi) {
            self.session.addInput(vi)
        }
        if let ai = audioInput, self.session.canAddInput(ai) {
            self.session.addInput(ai)
        }
        // 将输出流添加到session
        if self.session.canAddOutput(self.imageOutput) {
            self.session.addOutput(self.imageOutput)
        }
        if self.session.canAddOutput(self.movieFileOutput) {
            self.session.addOutput(self.movieFileOutput)
        }
        // 预览layer
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
        self.previewLayer?.videoGravity = .resizeAspect
        self.view.layer.masksToBounds = true
        self.view.layer.insertSublayer(self.previewLayer!, at: 0)
        
        self.cameraConfigureFinish = true
    }
    
    func getCamera(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let devices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: position).devices
        for device in devices {
            if device.position == position {
                return device
            }
        }
        return nil
    }
    
    func getMicrophone() -> AVCaptureDevice? {
        return AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInMicrophone], mediaType: .audio, position: .unspecified).devices.first
    }
    
    func addNotification() {
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
    
    }
    
    func showAlertAndDismissAfterDoneAction(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: localLanguageTextValue(.done), style: .default) { (_) in
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(action)
        self.showDetailViewController(alert, sender: nil)
    }
    
    func showTipsLabel(animate: Bool) {
        self.tipsLabel.layer.removeAllAnimations()
        if animate {
            UIView.animate(withDuration: 0.25) {
                self.tipsLabel.alpha = 1
            }
        } else {
            self.tipsLabel.alpha = 1
        }
        //  self.startHideTipsLabelTimer()
    }
    
    func hideTipsLabel(animate: Bool) {
        self.cleanTimer()
        self.tipsLabel.layer.removeAllAnimations()
        if animate {
            UIView.animate(withDuration: 0.25) {
                self.tipsLabel.alpha = 0
            }
        } else {
            self.tipsLabel.alpha = 0
        }
    }
    
    func startHideTipsLabelTimer() {
        self.cleanTimer()
        self.hideTipsTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { (timer) in
            self.hideTipsLabel(animate: true)
        })
    }
    
    func cleanTimer() {
        self.hideTipsTimer?.invalidate()
        self.hideTipsTimer = nil
    }
    
    @objc func appWillResignActive() {
        if self.session.isRunning {
            self.dismiss(animated: true, completion: nil)
        }
    }
    

    
    @objc
    func dismissBtnClick(){
        dismiss(animated: true, completion: nil)

    }
    
    
    @objc
    func retakeBtnClick(){
        angleX = 0
        
        takedImageView.transform = .identity
        takedImageView.frame = view.bounds
        
        
        session.startRunning()
        resetSubViewStatus()
        takedImage = nil
        
    }
    

    
    @objc func doneBtnClick() {
        recordVideoPlayerLayer?.player?.pause()
        recordVideoPlayerLayer?.player = nil
        dismiss(animated: true) {
            self.takeDoneBlock?(self.takedImage?.image(rotated: Int(self.angleX)))
        }
    }
    
    // 点击拍照
    @objc func takePicture() {
        let connection = self.imageOutput.connection(with: .video)
        connection?.videoOrientation = self.orientation
        if self.videoInput?.device.position == .front, connection?.isVideoMirroringSupported == true {
            connection?.isVideoMirrored = true
        }
        let setting = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        if self.videoInput?.device.hasFlash == true {
            setting.flashMode = ZLPhotoConfiguration.default().cameraFlashMode.avFlashMode
        }
        self.imageOutput.capturePhoto(with: setting, delegate: self)
    }
    

    
    // 调整焦点
    @objc func adjustFocusPoint(_ tap: UITapGestureRecognizer) {
        guard self.session.isRunning else {
            return
        }
        let point = tap.location(in: self.view)
        if point.y > self.bottomView.frame.minY - 30 {
            return
        }
        self.setFocusCusor(point: point)
    }
    
    func setFocusCusor(point: CGPoint) {
        
        // ui坐标转换为摄像头坐标
        let cameraPoint = self.previewLayer?.captureDevicePointConverted(fromLayerPoint: point) ?? self.view.center
        self.focusCamera(mode: .autoFocus, exposureMode: .autoExpose, point: cameraPoint)
    }
    

    
    func setVideoZoomFactor(_ zoomFactor: CGFloat) {
        guard let device = self.videoInput?.device else {
            return
        }
        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = zoomFactor
            device.unlockForConfiguration()
        } catch {
            zl_debugPrint("调整焦距失败 \(error.localizedDescription)")
        }
    }
    
    
    func focusCamera(mode: AVCaptureDevice.FocusMode, exposureMode: AVCaptureDevice.ExposureMode, point: CGPoint) {
        do {
            guard let device = self.videoInput?.device else {
                return
            }
            
            try device.lockForConfiguration()
            
            if device.isFocusModeSupported(mode) {
                device.focusMode = mode
            }
            if device.isFocusPointOfInterestSupported {
                device.focusPointOfInterest = point
            }
            if device.isExposureModeSupported(exposureMode) {
                device.exposureMode = exposureMode
            }
            if device.isExposurePointOfInterestSupported {
                device.exposurePointOfInterest = point
            }
            
            device.unlockForConfiguration()
        } catch {
            zl_debugPrint("相机聚焦设置失败 \(error.localizedDescription)")
        }
    }
    

    
    func resetSubViewStatus() {
        
        let views: [UIView] = [retakeBtn, bottomBeach, upTitle,
                               upBitch, doneBtn, rotateBtn,
                               bg]
        
        if session.isRunning {
            self.showTipsLabel(animate: true)
            self.bottomView.isHidden = false
            self.dismissBtn.isHidden = false
            
            views.forEach { $0.isHidden = true }
            takedImageView.isHidden = true
            self.takedImage = nil
        }
        else {
            self.hideTipsLabel(animate: false)
            self.bottomView.isHidden = true
            self.dismissBtn.isHidden = true
            views.forEach { $0.isHidden = false }
        }
    }
    

}


extension ZLCustomCamera: AVCapturePhotoCaptureDelegate {
    
    
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if error != nil {
            zl_debugPrint("拍照失败 \(error?.localizedDescription ?? "")")
            return
        }
        
        if let imgData = photo.fileDataRepresentation(){
            self.session.stopRunning()
            if let img = UIImage(data: imgData){
                self.takedImage = img.fixOrientation()
            }
            self.takedImageView.image = self.takedImage
            self.takedImageView.isHidden = false
            self.resetSubViewStatus()
            
            
        }
    }
    
    
}



extension ZLCustomCamera: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {

        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if gestureRecognizer is UIPanGestureRecognizer, touch.view is UIControl {
            // 解决拖动改变焦距时，无法点击其他按钮的问题
            return false
        }
        return true
    }
    
}


extension ZLCustomCamera {
    
    @objc public enum CaptureSessionPreset: Int {
        
        var avSessionPreset: AVCaptureSession.Preset {
            switch self {
            case .cif352x288:
                return .cif352x288
            case .vga640x480:
                return .vga640x480
            case .hd1280x720:
                return .hd1280x720
            case .hd1920x1080:
                return .hd1920x1080
            case .hd4K3840x2160:
                return .hd4K3840x2160
            }
        }
        
        case cif352x288
        case vga640x480
        case hd1280x720
        case hd1920x1080
        case hd4K3840x2160
    }
    
    @objc public enum CameraFlashMode: Int  {
        
        // 转自定义相机
        var avFlashMode: AVCaptureDevice.FlashMode {
            switch self {
            case .auto:
                return .auto
            case .on:
                return .on
            case .off:
                return .off
            }
        }
        
        // 转系统相机
        var imagePickerFlashMode: UIImagePickerController.CameraFlashMode {
            switch self {
            case .auto:
                return .auto
            case .on:
                return .on
            case .off:
                return .off
            }
        }
        
        case auto
        case on
        case off
    }
    
    @objc public enum VideoExportType: Int {
        
        var format: String {
            switch self {
            case .mov:
                return "mov"
            case .mp4:
                return "mp4"
            }
        }
        
        var avFileType: AVFileType {
            switch self {
            case .mov:
                return .mov
            case .mp4:
                return .mp4
            }
        }
        
        case mov
        case mp4
    }
    
}
