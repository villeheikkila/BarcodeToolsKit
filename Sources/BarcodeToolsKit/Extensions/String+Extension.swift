extension String {
    var trimmedAndSpaceless: String {
        trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: "")
    }

    var isAllNumbers: Bool {
        allSatisfy { $0.isNumber }
    }
}
