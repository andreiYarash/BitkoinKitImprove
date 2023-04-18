enum BlockValidatorType { case header, bits, legacy, testNet, EDA, DAA, DGW }


protocol IHDWallet {
    var gapLimit: Int { get }
    func publicKey(account: Int, index: Int, external: Bool) throws -> PublicKey_Local_Usage
    func publicKeys(account: Int, indices: Range<UInt32>, external: Bool) throws -> [PublicKey_Local_Usage]
    func privateKeyData(account: Int, index: Int, external: Bool) throws -> Data
}

public protocol IRestoreKeyConverter {
    func keysForApiRestore(publicKey: PublicKey_Local_Usage) -> [String]
    func bloomFilterElements(publicKey: PublicKey_Local_Usage) -> [Data]
}

public protocol IPublicKeyManager {
    func changePublicKey() throws -> PublicKey_Local_Usage
    func receivePublicKey() throws -> PublicKey_Local_Usage
    func fillGap() throws
    func addKeys(keys: [PublicKey_Local_Usage])
    func gapShifts() -> Bool
    func publicKey(byPath: String) throws -> PublicKey_Local_Usage
}


public protocol IHasher {
    func hash(data: Data) -> Data
}

protocol IInitialSyncerDelegate: class {
    func onSyncSuccess()
    func onSyncFailed(error: Error)
}

protocol IPaymentAddressParser {
    func parse(paymentAddress: String) -> BitcoinPaymentData
}

public protocol IAddressConverter {
    func convert(address: String) throws -> Address_Local_Usage
    func convert(keyHash: Data, type: ScriptType_Local_Usage) throws -> Address_Local_Usage
    func convert(publicKey: PublicKey_Local_Usage, type: ScriptType_Local_Usage) throws -> Address_Local_Usage
}

public protocol IScriptConverter {
    func decode(data: Data) throws -> Script_Local_Usage
}

protocol IScriptExtractor: class {
    var type: ScriptType_Local_Usage { get }
    func extract(from data: Data, converter: IScriptConverter) throws -> Data?
}

protocol ITransactionLinker {
    func handle(transaction: FullTransaction)
}

protocol ITransactionPublicKeySetter {
    func set(output: Output) -> Bool
}

public protocol ITransactionSyncer: class {
    func newTransactions() -> [FullTransaction]
    func handleRelayed(transactions: [FullTransaction])
    func handleInvalid(fullTransaction: FullTransaction)
    func shouldRequestTransaction(hash: Data) -> Bool
}

public protocol ITransactionCreator {
    func createRawTransaction(to address: String, value: Int, feeRate: Int, senderPay: Bool, sortType: TransactionDataSortType, signatures: [Data], changeScript: Data?, sequence: Int, pluginData: [UInt8: IPluginData]) throws -> Data
    func createRawHashesToSign(to address: String, value: Int, feeRate: Int, senderPay: Bool, sortType: TransactionDataSortType, changeScript: Data?, sequence: Int, pluginData: [UInt8: IPluginData]) throws -> [Data]
}

protocol ITransactionBuilder {
    func buildTransaction(toAddress: String, value: Int, feeRate: Int, senderPay: Bool, sortType: TransactionDataSortType, signatures: [Data], changeScript: Data?, sequence: Int, pluginData: [UInt8: IPluginData]) throws -> FullTransaction
    
    func buildTransactionToSign(toAddress: String, value: Int, feeRate: Int, senderPay: Bool, sortType: TransactionDataSortType, changeScript: Data?, sequence: Int, pluginData: [UInt8: IPluginData]) throws -> [Data]
}

protocol ITransactionFeeCalculator {
    func fee(for value: Int, feeRate: Int, senderPay: Bool, toAddress: String?, changeScript: Data?, sequence: Int, pluginData: [UInt8: IPluginData]) throws -> Int
}

protocol IInputSigner {
    func sigScriptData(transaction: Transaction_Local_Usage, inputsToSign: [InputToSign], outputs: [Output], index: Int, inputSignature: Data) throws -> [Data]
    func sigScriptHashToSign(transaction: Transaction_Local_Usage, inputsToSign: [InputToSign], outputs: [Output], index: Int) throws -> Data
}

public protocol ITransactionSizeCalculator {
    func transactionSize(previousOutputs: [Output], outputScriptTypes: [ScriptType_Local_Usage]) -> Int
    func transactionSize(previousOutputs: [Output], outputScriptTypes: [ScriptType_Local_Usage], pluginDataOutputSize: Int) -> Int
    func outputSize(type: ScriptType_Local_Usage) -> Int
    func inputSize(type: ScriptType_Local_Usage) -> Int
    func witnessSize(type: ScriptType_Local_Usage) -> Int
    func toBytes(fee: Int) -> Int
}

public protocol IDustCalculator {
    func dust(type: ScriptType_Local_Usage) -> Int
}

public protocol IUnspentOutputSelector {
    func select(value: Int, feeRate: Int, outputScriptType: ScriptType_Local_Usage, changeType: ScriptType_Local_Usage, senderPay: Bool, pluginDataOutputSize: Int, feeCalculation: Bool) throws -> SelectedUnspentOutputInfo
}

public protocol IUnspentOutputProvider {
    var spendableUtxo: [UnspentOutput] { get }
}

public protocol IUnspentOutputsSetter {
    func setSpendableUtxos(_ utxos: [UnspentOutput])
}


public protocol INetwork: class {
    var pubKeyHash: UInt8 { get }
    var privateKey: UInt8 { get }
    var scriptHash: UInt8 { get }
    var bech32PrefixPattern: String { get }
    var xPubKey: UInt32 { get }
    var xPrivKey: UInt32 { get }
    var magic: UInt32 { get }
    var port: UInt32 { get }
    var dnsSeeds: [String] { get }
    var dustRelayTxFee: Int { get }
    var coinType: UInt32 { get }
    var sigHash: SigHashType { get }
}

protocol IIrregularOutputFinder {
    func hasIrregularOutput(outputs: [Output]) -> Bool
}

public protocol IPlugin {
    var id: UInt8 { get }
    var maxSpendLimit: Int? { get }
    func validate(address: Address_Local_Usage) throws
    func processOutputs(mutableTransaction: MutableTransaction, pluginData: IPluginData, skipChecks: Bool) throws
    func processTransactionWithNullData(transaction: FullTransaction, nullDataChunks: inout IndexingIterator<[Chunk]>) throws
    func isSpendable(unspentOutput: UnspentOutput) throws -> Bool
    func inputSequenceNumber(output: Output) throws -> Int
    func parsePluginData(from: String, transactionTimestamp: Int) throws -> IPluginOutputData
    func keysForApiRestore(publicKey: PublicKey_Local_Usage) throws -> [String]
}

public protocol IPluginManager {
    func validate(address: Address_Local_Usage, pluginData: [UInt8: IPluginData]) throws
    func maxSpendLimit(pluginData: [UInt8: IPluginData]) throws -> Int?
    func add(plugin: IPlugin)
    func processOutputs(mutableTransaction: MutableTransaction, pluginData: [UInt8: IPluginData], skipChecks: Bool) throws
    func processInputs(mutableTransaction: MutableTransaction) throws
    func processTransactionWithNullData(transaction: FullTransaction, nullDataOutput: Output) throws
    func isSpendable(unspentOutput: UnspentOutput) -> Bool
    func parsePluginData(fromPlugin: UInt8, pluginDataString: String, transactionTimestamp: Int) -> IPluginOutputData?
}

protocol IRecipientSetter {
    func setRecipient(to mutableTransaction: MutableTransaction, toAddress: String, value: Int, pluginData: [UInt8: IPluginData], skipChecks: Bool) throws
}

protocol IOutputSetter {
    func setOutputs(to mutableTransaction: MutableTransaction, sortType: TransactionDataSortType)
}

protocol IInputSetter {
    func setInputs(to mutableTransaction: MutableTransaction, feeRate: Int, senderPay: Bool, sortType: TransactionDataSortType, changeScript: Data?, sequence: Int, feeCalculation: Bool) throws
    func setInputs(to mutableTransaction: MutableTransaction, fromUnspentOutput unspentOutput: UnspentOutput, feeRate: Int, sequence: Int) throws
}

protocol ITransactionSigner {
    func sign(mutableTransaction: MutableTransaction, signatures: [Data]) throws
    func hashesToSign(mutableTransaction: MutableTransaction) throws -> [Data]
}

public protocol IPluginData {
}

public protocol IPluginOutputData {
}

public enum TransactionDataSortType { case none, shuffle, bip69 }


protocol ITransactionDataSorterFactory {
    func sorter(for type: TransactionDataSortType) -> ITransactionDataSorter
}

protocol ITransactionDataSorter {
    func sort(outputs: [Output]) -> [Output]
    func sort(unspentOutputs: [UnspentOutput]) -> [UnspentOutput]
}

protocol IFactory {
    func transaction(version: Int, lockTime: Int) -> Transaction_Local_Usage
    func inputToSign(withPreviousOutput: UnspentOutput, script: Data, sequence: Int) -> InputToSign
    func output(withIndex index: Int, address: Address_Local_Usage, value: Int, publicKey: PublicKey_Local_Usage?) -> Output
    func nullDataOutput(data: Data) -> Output
}
