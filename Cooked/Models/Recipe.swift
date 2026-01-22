import Foundation

struct Recipe: Codable, Identifiable, Sendable, Hashable {
    let id: UUID
    let userId: UUID
    var title: String
    var sourceType: SourceType?
    var sourceUrl: String?
    var sourceName: String?
    var ingredients: [Ingredient]
    var steps: [String]
    var tags: [String]
    var imageUrl: String?
    let createdAt: Date
    var timesCooked: Int

    enum SourceType: String, Codable, Sendable {
        case video
        case url
        case manual
    }

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case title
        case sourceType = "source_type"
        case sourceUrl = "source_url"
        case sourceName = "source_name"
        case ingredients
        case steps
        case tags
        case imageUrl = "image_url"
        case createdAt = "created_at"
        case timesCooked = "times_cooked"
    }

    // Custom decoder to handle missing/null fields from database
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(UUID.self, forKey: .id)
        userId = try container.decode(UUID.self, forKey: .userId)
        title = try container.decode(String.self, forKey: .title)
        sourceType = try container.decodeIfPresent(SourceType.self, forKey: .sourceType)
        sourceUrl = try container.decodeIfPresent(String.self, forKey: .sourceUrl)
        sourceName = try container.decodeIfPresent(String.self, forKey: .sourceName)
        ingredients = (try? container.decodeIfPresent([Ingredient].self, forKey: .ingredients)) ?? []
        steps = (try? container.decodeIfPresent([String].self, forKey: .steps)) ?? []
        tags = (try? container.decodeIfPresent([String].self, forKey: .tags)) ?? []
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        timesCooked = (try? container.decodeIfPresent(Int.self, forKey: .timesCooked)) ?? 0
    }

    // Manual initializer for creating new recipes
    init(
        id: UUID = UUID(),
        userId: UUID,
        title: String,
        sourceType: SourceType? = nil,
        sourceUrl: String? = nil,
        sourceName: String? = nil,
        ingredients: [Ingredient] = [],
        steps: [String] = [],
        tags: [String] = [],
        imageUrl: String? = nil,
        createdAt: Date = Date(),
        timesCooked: Int = 0
    ) {
        self.id = id
        self.userId = userId
        self.title = title
        self.sourceType = sourceType
        self.sourceUrl = sourceUrl
        self.sourceName = sourceName
        self.ingredients = ingredients
        self.steps = steps
        self.tags = tags
        self.imageUrl = imageUrl
        self.createdAt = createdAt
        self.timesCooked = timesCooked
    }

    static func == (lhs: Recipe, rhs: Recipe) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
