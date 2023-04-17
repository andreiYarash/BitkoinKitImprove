
public struct FullTransaction {

    public let header: Transaction_Local_Usage
    public let inputs: [Input]
    public let outputs: [Output]

    public init(header: Transaction_Local_Usage, inputs: [Input], outputs: [Output]) {
        self.header = header
        self.inputs = inputs
        self.outputs = outputs

        self.header.dataHash = TransactionSerializer.serialize(transaction: self, withoutWitness: true).doubleSha256()
        for input in self.inputs {
            input.transactionHash = self.header.dataHash
        }
        for output in self.outputs {
            output.transactionHash = self.header.dataHash
        }
    }

}

public struct InputToSign {

    let input: Input
    let previousOutput: Output
    let previousOutputPublicKey: PublicKey_Local_Usage

}

public struct OutputWithPublicKey {

    let output: Output
    let publicKey: PublicKey_Local_Usage
    let spendingInput: Input?
    let spendingBlockHeight: Int?

}

struct InputWithPreviousOutput {

    let input: Input
    let previousOutput: Output?

}

public struct TransactionWithBlock {

    public let transaction: Transaction_Local_Usage
    let blockHeight: Int?

}

public struct UnspentOutput {

    public let output: Output
    public let publicKey: PublicKey_Local_Usage
    public let transaction: Transaction_Local_Usage
    public let blockHeight: Int?

    public init(output: Output, publicKey: PublicKey_Local_Usage, transaction: Transaction_Local_Usage, blockHeight: Int? = nil) {
        self.output = output
        self.publicKey = publicKey
        self.transaction = transaction
        self.blockHeight = blockHeight
    }

}

public struct FullTransactionForInfo {

    public let transactionWithBlock: TransactionWithBlock
    let inputsWithPreviousOutputs: [InputWithPreviousOutput]
    let outputs: [Output]

    var rawTransaction: String {
        let fullTransaction = FullTransaction(
                header: transactionWithBlock.transaction,
                inputs: inputsWithPreviousOutputs.map { $0.input },
                outputs: outputs
        )

        return TransactionSerializer.serialize(transaction: fullTransaction).hex
    }

}

public struct PublicKeyWithUsedState {

    let publicKey: PublicKey_Local_Usage
    let used: Bool

}
