public class AddressConverterChain: IAddressConverter {
    private var concreteConverters = [IAddressConverter]()

    func prepend(addressConverter: IAddressConverter) {
        concreteConverters.insert(addressConverter, at: 0)
    }

    public func convert(address: String) throws -> Address_Local_Usage {
        var errors = [Error]()

        for converter in concreteConverters {
            do {
                let converted = try converter.convert(address: address)
                return converted
            } catch {
                errors.append(error)
            }
        }

        throw BitcoinCoreErrors.AddressConversionErrors(errors: errors)
    }

    public func convert(keyHash: Data, type: ScriptType_Local_Usage) throws -> Address_Local_Usage {
        var errors = [Error]()

        for converter in concreteConverters {
            do {
                let converted = try converter.convert(keyHash: keyHash, type: type)
                return converted
            } catch {
                errors.append(error)
            }
        }

        throw BitcoinCoreErrors.AddressConversionErrors(errors: errors)
    }

    public func convert(publicKey: PublicKey_Local_Usage, type: ScriptType_Local_Usage) throws -> Address_Local_Usage {
        var errors = [Error]()

        for converter in concreteConverters {
            do {
                let converted = try converter.convert(publicKey: publicKey, type: type)
                return converted
            } catch {
                errors.append(error)
            }
        }

        throw BitcoinCoreErrors.AddressConversionErrors(errors: errors)
    }

}
