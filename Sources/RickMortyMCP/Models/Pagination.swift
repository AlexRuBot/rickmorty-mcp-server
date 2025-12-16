import Foundation

struct Info: Codable {
    let count: Int
    let pages: Int
    let next: String?
    let prev: String?
}

struct PaginatedResponse<T: Codable>: Codable {
    let info: Info
    let results: [T]
}
