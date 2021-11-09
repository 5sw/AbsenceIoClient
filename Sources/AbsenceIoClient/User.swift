public struct User: Entity {
    public static let endpoint: String = "users"

    public var name: String
    public var firstName: String
    public var lastName: String
    public var nameByLastname: String

    public var timeZone: String

    public var teamIds: [String]
    public var teams: [Team]?

    public struct Team: Decodable {
        public var _id: String
        public var name: String
        public var company: String
        public var icsLink: String?
    }
}
