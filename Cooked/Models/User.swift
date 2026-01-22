import Foundation

struct User: Codable, Identifiable, Sendable {
    let id: UUID
    let email: String
    var subscriptionStatus: SubscriptionStatus

    enum SubscriptionStatus: String, Codable, Sendable {
        case free
        case pro
    }

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case subscriptionStatus = "subscription_status"
    }
}
