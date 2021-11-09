public struct Team: Decodable, Entity {
    public static let endpoint: String = "teams"

    public var _id: String
    public var name: String
}
