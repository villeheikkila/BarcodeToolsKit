import SwiftUI
import Vision
import VisionKit

#if os(iOS) || os(visionOS)
    struct BarcodeDataScannerView: View {
        let onDataFound: (_ barcode: Barcode?) -> Void
        let recognizedSymbologies: [VNBarcodeSymbology]

        var body: some View {
            DataScannerViewRepresentable(
                recognizedDataTypes: [.barcode(symbologies: recognizedSymbologies)],
                onDataFound: { data in
                    if case let .barcode(foundBarcode) = data, let payloadStringValue = foundBarcode.payloadStringValue {
                        onDataFound(.init(rawValue: payloadStringValue))
                    }
                }
            )
        }
    }

    struct DataScannerViewRepresentable: UIViewControllerRepresentable {
        typealias DataFoundCallback = (RecognizedItem) -> Void
        let recognizedDataTypes: Set<DataScannerViewController.RecognizedDataType>
        let onDataFound: DataScannerViewRepresentable.DataFoundCallback

        func makeUIViewController(context _: Context) -> DataScannerViewController {
            DataScannerViewController(
                recognizedDataTypes: recognizedDataTypes,
                qualityLevel: .balanced,
                recognizesMultipleItems: false,
                isPinchToZoomEnabled: true,
                isGuidanceEnabled: true,
                isHighlightingEnabled: true
            )
        }

        func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
            uiViewController.delegate = context.coordinator
            try? uiViewController.startScanning()
        }

        func makeCoordinator() -> Coordinator {
            Coordinator(onDataFound: onDataFound)
        }

        static func dismantleUIViewController(_ uiViewController: DataScannerViewController, coordinator _: Coordinator) {
            uiViewController.stopScanning()
        }
    }

    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        let onDataFound: DataScannerViewRepresentable.DataFoundCallback

        init(onDataFound: @escaping DataScannerViewRepresentable.DataFoundCallback) {
            self.onDataFound = onDataFound
        }

        func dataScanner(_: DataScannerViewController, didTapOn: RecognizedItem) {
            onDataFound(didTapOn)
        }

        func dataScanner(_: DataScannerViewController, didAdd: [RecognizedItem], allItems _: [RecognizedItem]) {
            if let found = didAdd.first {
                onDataFound(found)
            }
        }

        func dataScanner(_: DataScannerViewController, didRemove _: [RecognizedItem], allItems _: [RecognizedItem]) {}

        func dataScanner(_: DataScannerViewController, becameUnavailableWithError _: DataScannerViewController.ScanningUnavailable) {}
    }
#endif
