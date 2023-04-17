import Foundation

class TransactionOutputSerializer {

     static func serialize(output: Output) -> Data {
        var data = Data()

        data += output.value
        let scriptLength = VarInt_Local_Usage(output.lockingScript.count)
        data += scriptLength.serialized()
        data += output.lockingScript

        return data
    }

    static func deserialize(byteStream: ByteStream_Local_Usage) -> Output {
        let value = Int(byteStream.read(Int64.self))
        let scriptLength: VarInt_Local_Usage = byteStream.read(VarInt_Local_Usage.self)
        let lockingScript = byteStream.read(Data.self, count: Int(scriptLength.underlyingValue))

        return Output(withValue: value, index: 0, lockingScript: lockingScript)
    }

}
