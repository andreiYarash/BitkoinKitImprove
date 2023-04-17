import Foundation

public class Script_Local_Usage {
    public let scriptData: Data
    public let chunks: [Chunk]

    public var length: Int { return scriptData.count }

    public func validate(opCodes: Data) throws {
        guard opCodes.count == chunks.count else {
            throw ScriptError_Local_Usage.wrongScriptLength
        }
        try chunks.enumerated().forEach { (index, chunk) in
            if chunk.opCode != opCodes[index] {
                throw ScriptError_Local_Usage.wrongSequence
            }
        }
    }

    public init(with data: Data, chunks: [Chunk]) {
        self.scriptData = data
        self.chunks = chunks
    }

}

public class ScriptBuilder {
    
    public static func createOutputScriptData(for address: Address_Local_Usage) throws -> Data {
        let scriptData: Data
        if let segwit = address as? SegWitAddress_Local_Usage {
            scriptData = segwit.lockingScript
        } else {
            switch address.scriptType {
            case .p2pkh:
                scriptData = OpCode_Local_Usage.p2pkhStart + OpCode_Local_Usage.push(address.keyHash) + OpCode_Local_Usage.p2pkhFinish
            case .p2sh:
                scriptData = OpCode_Local_Usage.p2shStart + OpCode_Local_Usage.push(address.keyHash) + OpCode_Local_Usage.p2shFinish
            default:
                throw ScriptError_Local_Usage.wrongSequence
            }
        }
        return scriptData
    }
    
    public static func createOutputScript(for address: Address_Local_Usage) throws -> Script_Local_Usage {
        let converter = ScriptConverter()
        let scriptData = try createOutputScriptData(for: address)
        return try converter.decode(data: scriptData)
    }
}
