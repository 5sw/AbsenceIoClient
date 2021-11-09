public protocol Entity: Decodable {
    static var endpoint: String { get }
    static var responseModel: String? { get }
}

public extension Entity {
    static var responseModel: String? { nil }
}
