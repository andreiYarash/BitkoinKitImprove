public class SegWitBech32AddressConverter: IAddressConverter {
    private let prefix: String
    private let scriptConverter: IScriptConverter

    public init(prefix: String, scriptConverter: IScriptConverter) {
        self.prefix = prefix
        self.scriptConverter = scriptConverter
    }

    public func convert(address: String) throws -> Address_Local_Usage {
        if let segWitData = try? SegWitBech32.decode(hrp: prefix, addr: address) {
            var type: AddressType_Local_Usage = .pubKeyHash
            if segWitData.version == 0 {
                switch segWitData.program.count {
                    case 32: type = .scriptHash
                    default: break
                }
            }
            return SegWitAddress_Local_Usage(type: type, keyHash: segWitData.program, bech32: address, version: segWitData.version)
        }
        throw BitcoinCoreErrors.AddressConversion.unknownAddressType
    }

    public func convert(keyHash: Data, type: ScriptType_Local_Usage) throws -> Address_Local_Usage {
        let script = try scriptConverter.decode(data: keyHash)
        guard script.chunks.count == 2,
              let versionCode = script.chunks.first?.opCode,
              let versionByte = OpCode_Local_Usage.value(fromPush: versionCode),
              let keyHash = script.chunks.last?.data else {
            throw BitcoinCoreErrors.AddressConversion.invalidAddressLength
        }
        let addressType: AddressType_Local_Usage
        switch type {
            case .p2wpkh:
                addressType = AddressType_Local_Usage.pubKeyHash
            case .p2wsh:
                addressType = AddressType_Local_Usage.scriptHash
            default: throw BitcoinCoreErrors.AddressConversion.unknownAddressType
        }
        let bech32 = try SegWitBech32.encode(hrp: prefix, version: versionByte, program: keyHash)
        return SegWitAddress_Local_Usage(type: addressType, keyHash: keyHash, bech32: bech32, version: versionByte)
    }

    public func convert(publicKey: PublicKey_Local_Usage, type: ScriptType_Local_Usage) throws -> Address_Local_Usage {
        try convert(keyHash: OpCode_Local_Usage.scriptWPKH(publicKey.keyHash), type: type)
    }
	
	public func convert(scriptHash: Data) throws -> Address_Local_Usage {
		try convert(keyHash: OpCode_Local_Usage.scriptWPKH(scriptHash), type: .p2wsh)
	}

}
