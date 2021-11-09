public struct Reason: Decodable, Entity {
    public static let endpoint: String = "reasons"

    public var _id: String
    public var name: String
}
