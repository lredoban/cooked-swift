import Foundation

/// A recipe saved in the user's library.
///
/// Recipes can be imported from URLs, videos (TikTok, Instagram, YouTube),
/// or created manually. They contain ingredients, steps, and metadata
/// for cooking and organization.
///
/// ## Topics
///
/// ### Creating Recipes
/// - ``init(id:userId:title:sourceType:sourceUrl:sourceName:ingredients:steps:tags:imageUrl:createdAt:timesCooked:)``
///
/// ### Source Types
/// - ``SourceType``
struct Recipe: Codable, Identifiable, Sendable, Hashable {
    /// Unique identifier for the recipe
    let id: UUID

    /// ID of the user who owns this recipe
    let userId: UUID

    /// Display title of the recipe
    var title: String

    /// How the recipe was imported (video, URL, or manual entry)
    var sourceType: SourceType?

    /// Original URL where the recipe was imported from
    var sourceUrl: String?

    /// Name of the source (e.g., website name or content creator)
    var sourceName: String?

    /// List of ingredients required for this recipe
    var ingredients: [Ingredient]

    /// Ordered list of cooking instructions
    var steps: [String]

    /// User-defined or auto-generated tags for organization
    var tags: [String]

    /// URL to the recipe's cover image
    var imageUrl: String?

    /// When the recipe was first saved
    let createdAt: Date

    /// Number of times the user has cooked this recipe
    var timesCooked: Int

    /// Current import status for async extraction flow
    var importStatus: ImportStatus

    /// The source type for how a recipe was imported into the app.
    enum SourceType: String, Codable, Sendable {
        /// Imported from a video platform (TikTok, Instagram, YouTube)
        case video
        /// Imported from a recipe website URL
        case url
        /// Manually entered by the user
        case manual
    }

    /// Import lifecycle status for async extraction flow.
    enum ImportStatus: String, Codable, Sendable {
        /// Metadata saved, extraction in progress
        case importing
        /// Extraction complete, user hasn't reviewed yet
        case pendingReview = "pending_review"
        /// User has reviewed and saved the recipe
        case active
        /// Extraction failed
        case failed
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
        case importStatus = "status"
    }

    /// Creates a recipe by decoding from Supabase JSON response.
    ///
    /// Handles missing or null fields gracefully by using default values.
    /// - Parameter decoder: The decoder to read data from
    /// - Throws: `DecodingError` if required fields are missing
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
        importStatus = (try? container.decodeIfPresent(ImportStatus.self, forKey: .importStatus)) ?? .active
    }

    /// Creates a new recipe with the specified properties.
    ///
    /// Use this initializer when creating recipes locally before saving to the database.
    ///
    /// - Parameters:
    ///   - id: Unique identifier (auto-generated if not provided)
    ///   - userId: ID of the user who owns this recipe
    ///   - title: Display title of the recipe
    ///   - sourceType: How the recipe was imported
    ///   - sourceUrl: Original URL where the recipe was found
    ///   - sourceName: Name of the source website or creator
    ///   - ingredients: List of ingredients required
    ///   - steps: Ordered cooking instructions
    ///   - tags: Tags for organization
    ///   - imageUrl: URL to cover image
    ///   - createdAt: Creation timestamp (defaults to now)
    ///   - timesCooked: Number of times cooked (defaults to 0)
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
        timesCooked: Int = 0,
        importStatus: ImportStatus = .active
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
        self.importStatus = importStatus
    }

    static func == (lhs: Recipe, rhs: Recipe) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.importStatus == rhs.importStatus &&
        lhs.ingredients == rhs.ingredients &&
        lhs.steps == rhs.steps &&
        lhs.tags == rhs.tags &&
        lhs.timesCooked == rhs.timesCooked
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
