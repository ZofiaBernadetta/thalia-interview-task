import Dispatch

public final class SynchronizedStorage<T>: @unchecked Sendable, RawRepresentable {
    private var storedValue: T
    private let queue = DispatchQueue(label: "de.thalia.SynchronizedStorage.\(String(describing: T.self))")

    public var rawValue: T {
        get { queue.sync { storedValue } }
        set { queue.sync { storedValue = newValue } }
    }

    public init(rawValue: T) {
        storedValue = rawValue
    }
}
