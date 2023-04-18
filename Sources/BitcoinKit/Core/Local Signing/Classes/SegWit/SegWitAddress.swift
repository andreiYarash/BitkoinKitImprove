public class SegWitAddress_Local_Usage: Address_Local_Usage, Equatable {
    public let type: AddressType_Local_Usage
    public let keyHash: Data
    public let stringValue: String
    public let version: UInt8

    public var scriptType: ScriptType_Local_Usage {
        switch type {
        case .pubKeyHash: return .p2wpkh
        case .scriptHash: return .p2wsh
        }
    }

    public var lockingScript: Data {
        // Data[0] - version byte, Data[1] - push keyHash
        OpCode_Local_Usage.push(Int(version)) + OpCode_Local_Usage.push(keyHash)
    }

    public init(type: AddressType_Local_Usage, keyHash: Data, bech32: String, version: UInt8) {
        self.type = type
        self.keyHash = keyHash
        self.stringValue = bech32
        self.version = version
    }

    static public func ==<T: Address_Local_Usage>(lhs: SegWitAddress_Local_Usage, rhs: T) -> Bool {
        guard let rhs = rhs as? SegWitAddress_Local_Usage else {
            return false
        }
        return lhs.type == rhs.type && lhs.keyHash == rhs.keyHash && lhs.version == rhs.version
    }
}
