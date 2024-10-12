import BarcodeToolsKit
import SwiftUI

struct ContentView: View {
    @State private var showScanner = false
    @State private var scannerBarcode: Barcode?
    var body: some View {
        NavigationStack {
            List {
                if let scannerBarcode {
                    VStack {
                        Text("Scanned Barcode")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        BarcodeView(barcode: scannerBarcode)
                            .frame(width: 200, height: 100)
                    }
                }
                VStack {
                    Text("EAN-13")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    BarcodeView(barcode: "6410405176059")
                        .frame(width: 200, height: 100)
                }
                VStack {
                    Text("EAN-8")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    BarcodeView(barcode: "20886509")
                        .frame(width: 200, height: 100)
                }
                VStack {
                    Text("UPC-A")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    BarcodeView(barcode: "123456789012")
                        .frame(width: 200, height: 100)
                }
                VStack {
                    Text("UPC-E")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    BarcodeView(barcode: "04252614")
                        .frame(width: 150, height: 100)
                }
            }
            .barcodeLineColor(.primary)
            .listStyle(.plain)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Show Scanner") {
                        showScanner = true
                    }
                }
            }
            .sheet(isPresented: $showScanner, content: { BarcodeScannerView(onDataFound: { barcode in scannerBarcode = barcode
                showScanner = false
            })
            })
        }
    }
}

#Preview {
    ContentView()
}
