import Foundation

public class PublicKey_Local_Usage {

    enum InitError: Error {
        case invalid
        case wrongNetwork
    }

    public let path: String
    public let account: Int
    public let index: Int
    public let external: Bool
    public let raw: Data
    public let keyHash: Data
    public let scriptHashForP2WPKH: Data

    public init(withAccount account: Int, index: Int, external: Bool, hdPublicKeyData data: Data) {
        self.account = account
        self.index = index
        self.external = external
        path = "\(account)/\(external ? 1 : 0)/\(index)"
        raw = data
        keyHash = data.sha256Ripemd160
        scriptHashForP2WPKH = OpCode_Local_Usage.scriptWPKH(keyHash).sha256Ripemd160
    }
}
