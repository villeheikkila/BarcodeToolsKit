public enum Barcode {
    case ean13(String)
    case ean8(String)
    
    public init?(rawValue: String) {
        let trimmedString = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedString.count == 13 {
            self = .ean13(trimmedString)
        } else if trimmedString.count == 8 {
            self = .ean8(trimmedString)
        } else {
            return nil
        }
        
        if !self.isValid {
            return nil
        }
    }

    public var isValid: Bool {
        switch self {
        case let .ean13(barcode):
            guard barcode.count == 13 else { return false }
            let digits = barcode.compactMap { Int(String($0)) }
            guard digits.count == 13 else { return false }
            guard let checkDigit = digits.last else { return false }
            let sum = digits
                .dropLast()
                .enumerated()
                .reduce(0) { total, curr in
                    total + (curr.element * (curr.offset.isMultiple(of: 2) ? 1 : 3))
                }
            let calculatedCheckDigit = (10 - (sum % 10)) % 10
            return checkDigit == calculatedCheckDigit
        case let .ean8(barcode):
            guard barcode.count == 8 else { return false }
            let digits = barcode.compactMap { Int(String($0)) }
            guard digits.count == 8 else { return false }
            guard let checkDigit = digits.last else { return false }
            let sum = digits
                .dropLast()
                .enumerated()
                .reduce(0) { total, curr in
                    total + (curr.element * (curr.offset.isMultiple(of: 2) ? 3 : 1))
                }
            let calculatedCheckDigit = (10 - (sum % 10)) % 10
            return checkDigit == calculatedCheckDigit
        }
    }
}
