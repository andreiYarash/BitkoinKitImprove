import Foundation

public class TransactionSerializer {

    static public func serialize(transaction: FullTransaction, withoutWitness: Bool = false) -> Data {
        let header = transaction.header
        var data = Data()

        data += UInt32(header.version)
        if header.segWit && !withoutWitness {
            data += UInt8(0)       // marker 0x00
            data += UInt8(1)       // flag 0x01
        }
        data += VarInt_Local_Usage(transaction.inputs.count).serialized()
        data += transaction.inputs.flatMap { TransactionInputSerializer.serialize(input: $0) }
        data += VarInt_Local_Usage(transaction.outputs.count).serialized()
        data += transaction.outputs.flatMap { TransactionOutputSerializer.serialize(output: $0) }
        if header.segWit && !withoutWitness {
            data += transaction.inputs.flatMap {
                DataListSerializer.serialize(dataList: $0.witnessData)
            }
        }
        data += UInt32(header.lockTime)

        return data
    }

    static public func serializedForSignature(transaction: Transaction_Local_Usage, inputsToSign: [InputToSign], outputs: [Output], inputIndex: Int, forked: Bool = false) throws -> Data {
        var data = Data()

        if forked {     // use bip143 for new transaction digest algorithm
            data += UInt32(transaction.version)

            let hashPrevouts = try inputsToSign.flatMap { input in
                try TransactionInputSerializer.serializedOutPoint(input: input)
            }
            data += Data(hashPrevouts).doubleSha256()

            var sequences = Data()
            for inputToSign in inputsToSign {
                sequences += UInt32(inputToSign.input.sequence)
            }
            data += sequences.doubleSha256()

            let inputToSign = inputsToSign[inputIndex]

            data += try TransactionInputSerializer.serializedOutPoint(input: inputToSign)

            switch inputToSign.previousOutput.scriptType {
			case .p2sh, .p2wsh:
                guard let script = inputToSign.previousOutput.redeemScript else {
                    throw SerializationError.noPreviousOutputScript
                }
                let scriptLength = VarInt(script.count)
                data += scriptLength.serialized()
                data += script
			case .p2wpkh:
				guard let script = inputToSign.previousOutput.redeemScript else {
					throw SerializationError.noPreviousOutputScript
				}
				data += script
            default:
                data += OpCode_Local_Usage.push(OpCode_Local_Usage.p2pkhStart + OpCode_Local_Usage.push(inputToSign.previousOutput.keyHash!) + OpCode_Local_Usage.p2pkhFinish)
            }

            data += inputToSign.previousOutput.value
            data += UInt32(inputToSign.input.sequence)

            let hashOutputs = outputs.flatMap { TransactionOutputSerializer.serialize(output: $0) }
            data += Data(hashOutputs).doubleSha256()
        } else {
            data += UInt32(transaction.version)
            data += VarInt_Local_Usage(inputsToSign.count).serialized()
			
            data += try inputsToSign.enumerated().flatMap { index, input in
                try TransactionInputSerializer.serializedForSignature(inputToSign: input, forCurrentInputSignature: inputIndex == index)
            }
            data += VarInt_Local_Usage(outputs.count).serialized()
            data += outputs.flatMap { TransactionOutputSerializer.serialize(output: $0) }
        }

        data += UInt32(transaction.lockTime)

        return data
    }

    static public func deserialize(data: Data) -> FullTransaction {
        return deserialize(byteStream: ByteStream_Local_Usage(data))
    }

    static public func deserialize(byteStream: ByteStream_Local_Usage) -> FullTransaction {
        let transaction = Transaction_Local_Usage()
        var inputs = [Input]()
        var outputs = [Output]()

        transaction.version = Int(byteStream.read(Int32.self))
        // peek at marker
        if let marker = byteStream.last {
            transaction.segWit = marker == 0
        }
        // marker, flag
        if transaction.segWit {
            _ = byteStream.read(Int16.self)
        }

        let txInCount = byteStream.read(VarInt_Local_Usage.self)
        for _ in 0..<Int(txInCount.underlyingValue) {
            inputs.append(TransactionInputSerializer.deserialize(byteStream: byteStream))
        }

        let txOutCount = byteStream.read(VarInt_Local_Usage.self)
        for i in 0..<Int(txOutCount.underlyingValue) {
            let output = TransactionOutputSerializer.deserialize(byteStream: byteStream)
            output.index = i
            outputs.append(output)
        }

        if transaction.segWit {
            for i in 0..<Int(txInCount.underlyingValue) {
                inputs[i].witnessData = DataListSerializer.deserialize(byteStream: byteStream)
            }
        }

        transaction.lockTime = Int(byteStream.read(UInt32.self))

        return FullTransaction(header: transaction, inputs: inputs, outputs: outputs)
    }

}