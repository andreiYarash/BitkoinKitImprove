import Foundation

public class DataListSerializer {

    static func serialize(dataList: [Data]) -> Data {
        var data = Data()
        data += VarInt_Local_Usage(dataList.count).serialized()
        for witness in dataList {
            data += VarInt_Local_Usage(witness.count).serialized() + witness
        }
        return data
    }

    static func deserialize(byteStream: ByteStream_Local_Usage) -> [Data] {
        var data = [Data]()
        let count = byteStream.read(VarInt_Local_Usage.self)
        for _ in 0..<Int(count.underlyingValue) {
            let dataSize = byteStream.read(VarInt_Local_Usage.self)
            data.append(byteStream.read(Data.self, count: Int(dataSize.underlyingValue)))
        }

        return data
    }

    static func deserialize(data: Data) -> [Data] {
        return deserialize(byteStream: ByteStream_Local_Usage(data))
    }

}
