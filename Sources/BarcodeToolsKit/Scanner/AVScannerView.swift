import AVFoundation
import SwiftUI

#if os(iOS) || os(visionOS)
    public struct AVScannerView: UIViewControllerRepresentable {
        enum ScanError: Error {
            case badInput
            case badOutput
            case initError(_ error: Error)
            case permissionDenied
        }

        let onDataFound: (_ barcode: Barcode?) -> Void
        let recognizedSymbologies: [AVMetadataObject.ObjectType]

        public init(
            onDataFound: @escaping (_ barcode: Barcode?) -> Void,
            recognizedSymbologies: [AVMetadataObject.ObjectType]
        ) {
            self.onDataFound = onDataFound
            self.recognizedSymbologies = recognizedSymbologies
        }

        public func makeUIViewController(context _: Context) -> Controller {
            Controller(parentView: self)
        }

        public func updateUIViewController(_ uiViewController: Controller, context _: Context) {
            uiViewController.parentView = self
            uiViewController.updateViewController()
        }
    }

    public extension AVScannerView {
        final class Controller: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,
            AVCaptureMetadataOutputObjectsDelegate
        {
            var parentView: AVScannerView?
            var didFinishScanning = false
            var lastTime = Date(timeIntervalSince1970: 0)
            var captureSession: AVCaptureSession?
            var previewLayer: AVCaptureVideoPreviewLayer?

            init(parentView: AVScannerView) {
                self.parentView = parentView
                super.init(nibName: nil, bundle: nil)
            }

            required init?(coder: NSCoder) {
                super.init(coder: coder)
            }

            override public func viewDidLoad() {
                super.viewDidLoad()
                setBackgroundColor()
                handleCameraPermission()
            }

            override public func viewWillLayoutSubviews() {
                previewLayer?.frame = view.layer.bounds
            }

            override public func viewDidAppear(_ animated: Bool) {
                super.viewDidAppear(animated)
            }

            override public func viewWillAppear(_ animated: Bool) {
                super.viewWillAppear(animated)
                setupSession()
            }

            private func setupSession() {
                guard let captureSession else {
                    return
                }

                if previewLayer == nil {
                    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                }

                guard let previewLayer else { return }

                previewLayer.frame = view.layer.bounds
                previewLayer.videoGravity = .resizeAspectFill
                view.layer.addSublayer(previewLayer)

                reset()
                Task.detached { [weak self] in
                    await self?.startCaptureSession()
                }
            }

            func startCaptureSession() {
                captureSession?.startRunning()
            }

            private func stopCaptureSession() {
                captureSession?.stopRunning()
            }

            private func handleCameraPermission() {
                switch AVCaptureDevice.authorizationStatus(for: .video) {
                case .restricted:
                    break
                case .denied:
                    didFail(reason: .permissionDenied)
                case .notDetermined:
                    requestCameraAccess {
                        self.setupCaptureDevice()
                        DispatchQueue.main.async {
                            self.setupSession()
                        }
                    }
                case .authorized:
                    setupCaptureDevice()
                    setupSession()
                default:
                    break
                }
            }

            private func requestCameraAccess(completion: (() -> Void)?) {
                Task {
                    let status = await AVCaptureDevice.requestAccess(for: .video)
                    guard status else {
                        self.didFail(reason: .permissionDenied)
                        return
                    }
                    completion?()
                }
            }

            private func setBackgroundColor(_ color: UIColor = .black) {
                view.backgroundColor = color
            }

            private func setupCaptureDevice() {
                captureSession = AVCaptureSession()
                guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
                    return
                }
                let videoInput: AVCaptureDeviceInput
                do {
                    videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
                } catch {
                    didFail(reason: .initError(error))
                    return
                }
                guard let captureSession else { return }
                if captureSession.canAddInput(videoInput) {
                    captureSession.addInput(videoInput)
                } else {
                    didFail(reason: .badInput)
                    return
                }
                let metadataOutput = AVCaptureMetadataOutput()
                if captureSession.canAddOutput(metadataOutput) {
                    captureSession.addOutput(metadataOutput)
                    metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                    guard let parentView else { return }
                    metadataOutput.metadataObjectTypes = parentView.recognizedSymbologies
                } else {
                    didFail(reason: .badOutput)
                    return
                }
            }

            override public func viewDidDisappear(_ animated: Bool) {
                super.viewDidDisappear(animated)
                if captureSession?.isRunning == true {
                    Task.detached { [weak self] in
                        await self?.stopCaptureSession()
                    }
                }
            }

            deinit {
                NotificationCenter.default.removeObserver(self)
            }

            override public var prefersStatusBarHidden: Bool {
                true
            }

            override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
                .all
            }

            override public func touchesBegan(_ touches: Set<UITouch>, with _: UIEvent?) {
                guard touches.first?.view == view,
                      let touchPoint = touches.first,
                      let device = AVCaptureDevice.default(for: .video),
                      device.isFocusPointOfInterestSupported
                else { return }

                let videoView = view
                guard let videoView else { return }
                let screenSize = videoView.bounds.size
                let xPoint = touchPoint.location(in: videoView).y / screenSize.height
                let yPoint = 1.0 - touchPoint.location(in: videoView).x / screenSize.width
                let focusPoint = CGPoint(x: xPoint, y: yPoint)

                do {
                    try device.lockForConfiguration()
                } catch {
                    return
                }

                device.focusPointOfInterest = focusPoint
                device.focusMode = .continuousAutoFocus
                device.exposurePointOfInterest = focusPoint
                device.exposureMode = AVCaptureDevice.ExposureMode.continuousAutoExposure
                device.unlockForConfiguration()
            }

            func updateViewController() {
                if let backCamera = AVCaptureDevice.default(for: AVMediaType.video),
                   backCamera.hasTorch
                {
                    try? backCamera.lockForConfiguration()
                    backCamera.unlockForConfiguration()
                }
            }

            func reset() {
                didFinishScanning = false
                lastTime = Date(timeIntervalSince1970: 0)
            }

            public nonisolated func metadataOutput(
                _: AVCaptureMetadataOutput,
                didOutput metadataObjects: [AVMetadataObject],
                from _: AVCaptureConnection
            ) {
                guard let metadataObject = metadataObjects.first else { return }
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
                guard let stringValue = readableObject.stringValue else { return }
                _ = readableObject.type.rawValue
                Task {
                    guard await didFinishScanning == false else { return }
                    guard let result = Barcode(rawValue: stringValue) else { return }
                    await MainActor.run {
                        found(result)
                        didFinishScanning = true
                    }
                }
            }

            func isPastScanInterval() -> Bool {
                Date().timeIntervalSince(lastTime) >= 2.0
            }

            func isWithinManualCaptureInterval() -> Bool {
                Date().timeIntervalSince(lastTime) <= 0.5
            }

            func found(_ result: Barcode) {
                lastTime = Date()
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                guard let parentView else { return }
                parentView.onDataFound(result)
            }

            func didFail(reason _: ScanError) {}
        }
    }
#endif
