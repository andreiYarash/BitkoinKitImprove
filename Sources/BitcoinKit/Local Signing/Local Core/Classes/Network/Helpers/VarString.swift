import Foundation

/// Variable length string can be stored using a variable length integer followed by the string itself.
public struct VarString_Local_Usage : ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    let length: VarInt_Local_Usage
    let value: String

    public init(stringLiteral value: String) {
        self.init(value)
    }

    init(_ value: String) {
        self.value = value
        length = VarInt_Local_Usage(value.data(using: .ascii)!.count)
    }

    func serialized() -> Data {
        var data = Data()
        data += length.serialized()
        data += value
        return data
    }
}

extension VarString_Local_Usage : CustomStringConvertible {
    public var description: String {
        return "\(value)"
    }
}
