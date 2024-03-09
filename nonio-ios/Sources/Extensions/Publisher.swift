import Foundation
import Combine

public extension Publisher {
    func flatMap<A: AnyObject, P: Publisher>(weak obj: A, transform: @escaping (A, Output) -> P) -> Publishers.FlatMap<P, Self> {
        flatMap { [weak obj] value in
            guard let obj = obj else {
                return Empty<Output, Failure>() as! P
            }

            return transform(obj, value)
        }
    }
}

public extension AnyPublisher where Failure: Error {

    static func value(_ value: Output) -> AnyPublisher<Output, Failure> {
        return Just(value)
            .setFailureType(to: Failure.self)
            .eraseToAnyPublisher()
    }

    static func error(_ error: Error) -> AnyPublisher<Output, Error> {
        return Fail(outputType: Output.self, failure: error)
            .eraseToAnyPublisher()
    }
}
