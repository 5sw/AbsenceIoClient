import Foundation
import SwiftHawk
import AsyncBackports

public struct Request<T: Entity>: Encodable {
    public var skip: Int = 0
    public var limit: Int
    public var filter: AnyFilter?
    public var relations: [String]

    public var responseModel: String? { T.responseModel }
    public var endpoint: String { T.endpoint }

    public init(skip: Int = 0, limit: Int = 0, filter: AnyFilter? = nil, relations: [String] = []) {
        self.skip = skip
        self.limit = limit
        self.filter = filter
        self.relations = relations
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(skip, forKey: .skip)
        try container.encode(limit, forKey: .limit)
        if let filter = filter {
            var filterContainer = container.nestedContainer(keyedBy: FilterKey.self, forKey: .filter)
            try filter.encode(container: &filterContainer)
        }
        try container.encodeIfPresent(responseModel, forKey: .responseModel)
        try container.encode(relations, forKey: .relations)
    }

    private enum CodingKeys: String, CodingKey {
        case skip = "skip"
        case limit = "limit"
        case filter = "filter"
        case responseModel = "responseModel"
        case relations = "relations"
    }

    func encode() throws -> Data {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy'-'MM'-'dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)

        let enc = JSONEncoder()
        enc.outputFormatting = .prettyPrinted
        enc.dateEncodingStrategy = .formatted(formatter)

        return try enc.encode(self)
    }

    public func send(credentials: HawkCredentials, urlSession: URLSession = URLSession.shared) async throws -> QueryResponse<T> {
        var request = URLRequest(url: URL(string: "https://app.absence.io/api/v2/\(endpoint)")!)

        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = try encode()

        request.sign(credentials: credentials)

        let (data, response) = try await urlSession.backport.data(for: request)

        guard let response = response as? HTTPURLResponse else {
            preconditionFailure("We only support HTTP")
        }

        guard 200..<300 ~= response.statusCode else {
            fatalError("TODO: Throw real error")
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(formatter)
        return try decoder.decode(QueryResponse<T>.self, from: data)
    }
}

public extension FilterKey {
    static let start = Self("start")
    static let end = Self("end")
    static let teamId = Self("teamId")
    static let id = Self("_id")
}

public struct QueryResponse<T: Entity & Decodable>: Decodable {
    public var data: [T]
    public var count: Int
    public var limit: Int
    public var skip: Int
    public var totalCount: Int
}
