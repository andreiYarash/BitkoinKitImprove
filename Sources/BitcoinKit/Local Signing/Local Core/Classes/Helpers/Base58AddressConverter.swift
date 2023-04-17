
public class Base58AddressConverter: IAddressConverter {
    private static let checkSumLength = 4
    private let addressVersion: UInt8
    private let addressScriptVersion: UInt8

    public init(addressVersion: UInt8, addressScriptVersion: UInt8) {
        self.addressVersion = addressVersion
        self.addressScriptVersion = addressScriptVersion
    }

    public func convert(address: String) throws -> Address_Local_Usage {
        // check length of address to avoid wrong converting
        guard address.count >= 26 && address.count <= 35 else {
            throw BitcoinCoreErrors.AddressConversion.invalidAddressLength
        }

        let hex = Base58_Local_Usage.decode(address)
        // check decoded length. Must be 1(version) + 20(KeyHash) + 4(CheckSum)
        if hex.count != Base58AddressConverter.checkSumLength + 20 + 1 {
            throw BitcoinCoreErrors.AddressConversion.invalidAddressLength
        }
        let givenChecksum = hex.suffix(Base58AddressConverter.checkSumLength)
        let doubleSHA256 = (hex.prefix(hex.count - Base58AddressConverter.checkSumLength)).doubleSha256()
        let actualChecksum = doubleSHA256.prefix(Base58AddressConverter.checkSumLength)
        guard givenChecksum == actualChecksum else {
            throw BitcoinCoreErrors.AddressConversion.invalidChecksum
        }

        let type: AddressType_Local_Usage
        switch hex[0] {
            case addressVersion: type = AddressType_Local_Usage.pubKeyHash
            case addressScriptVersion: type = AddressType_Local_Usage.scriptHash
            default: throw BitcoinCoreErrors.AddressConversion.wrongAddressPrefix
        }

        let keyHash = hex.dropFirst().dropLast(4)
        return LegacyAddress_Local_Usage(type: type, keyHash: keyHash, base58: address)
    }

    public func convert(keyHash: Data, type: ScriptType_Local_Usage) throws -> Address_Local_Usage {
        let version: UInt8
        let addressType: AddressType_Local_Usage

        switch type {
            case .p2pkh, .p2pk:
                version = addressVersion
                addressType = AddressType_Local_Usage.pubKeyHash
            case .p2sh, .p2wpkhSh:
                version = addressScriptVersion
                addressType = AddressType_Local_Usage.scriptHash
            default: throw BitcoinCoreErrors.AddressConversion.unknownAddressType
        }

        var withVersion = (Data([version])) + keyHash
        let doubleSHA256 = withVersion.doubleSha256()
        let checksum = doubleSHA256.prefix(4)
        withVersion += checksum
        let base58 = Base58_Local_Usage.encode(withVersion)
        return LegacyAddress_Local_Usage(type: addressType, keyHash: keyHash, base58: base58)
    }

    public func convert(publicKey: PublicKey_Local_Usage, type: ScriptType_Local_Usage) throws -> Address_Local_Usage {
        let keyHash = type == .p2wpkhSh ? publicKey.scriptHashForP2WPKH : publicKey.keyHash
        return try convert(keyHash: keyHash, type: type)
    }

}
