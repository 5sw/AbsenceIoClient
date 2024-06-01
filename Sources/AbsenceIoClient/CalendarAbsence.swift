import Foundation

public struct Absence: Entity, Encodable {
    public static let endpoint: String = "absences"
    public static let responseModel: String? = "Calendar"

    public var daysCount: Float
    public var start: Date
    public var end: Date
    public var reason: Reason?
    public var reasonId: String?
    public var assignedTo: Person
    public var approver: Person
    public var _id: String
    public var status: Int?

    public struct Reason: Codable {
        public var _id: String
        public var countsAsWork: Bool
        public var name: String
        public var color: Color

        public struct Color: Codable {
            public var colorValue: String
            public var imageLink: URL
        }
    }

    public struct Person: Codable {
        public var name: String
        public var email: String
        public var avatar: String?
        public var firstName: String
        public var lastName: String
        public var _id: String
    }
}
