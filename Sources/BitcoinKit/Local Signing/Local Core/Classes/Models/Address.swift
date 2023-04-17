import Foundation

public enum AddressType_Local_Usage: UInt8 { case pubKeyHash = 0, scriptHash = 8 }

public protocol Address_Local_Usage: class {
    var type: AddressType_Local_Usage { get }
    var scriptType: ScriptType_Local_Usage { get }
    var keyHash: Data { get }
    var stringValue: String { get }
    var lockingScript: Data { get }
}

extension Address_Local_Usage {

    public var scriptType: ScriptType_Local_Usage {
        switch type {
            case .pubKeyHash: return .p2pkh
            case .scriptHash: return .p2sh
        }
    }

}

public class LegacyAddress_Local_Usage: Address_Local_Usage, Equatable {
    public let type: AddressType_Local_Usage
    public let keyHash: Data
    public let stringValue: String

    public var lockingScript: Data {
        switch type {
        case .pubKeyHash: return OpCode_Local_Usage.p2pkhStart + OpCode_Local_Usage.push(keyHash) + OpCode_Local_Usage.p2pkhFinish
        case .scriptHash: return OpCode_Local_Usage.p2shStart + OpCode_Local_Usage.push(keyHash) + OpCode_Local_Usage.p2shFinish
        }
    }

    public init(type: AddressType_Local_Usage, keyHash: Data, base58: String) {
        self.type = type
        self.keyHash = keyHash
        self.stringValue = base58
    }

    public static func ==<T: Address_Local_Usage>(lhs: LegacyAddress_Local_Usage, rhs: T) -> Bool {
        guard let rhs = rhs as? LegacyAddress_Local_Usage else {
            return false
        }
        return lhs.type == rhs.type && lhs.keyHash == rhs.keyHash
    }
}
