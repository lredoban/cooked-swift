import Foundation
import Supabase
import Auth

@Observable
final class SupabaseService {
    static let shared = SupabaseService()

    let client: SupabaseClient

    private(set) var currentUser: User?
    private(set) var authUser: Auth.User?
    var isAuthenticated: Bool { authUser != nil }

    // Dev credentials for testing (remove in production)
    #if DEBUG
    private let devEmail = "test@cooked.dev"
    private let devPassword = "testpassword123"
    #endif

    private init() {
        client = SupabaseClient(
            supabaseURL: AppConfig.supabaseURL,
            supabaseKey: AppConfig.supabaseAnonKey,
            options: .init(
                auth: .init(emitLocalSessionAsInitialSession: true)
            )
        )
    }

    // MARK: - Connection Test

    func testConnection() async -> Bool {
        guard AppConfig.isConfigured else { return false }

        do {
            #if DEBUG
            try await signInWithDevUser()
            #endif

            let _: [Recipe] = try await client
                .from("recipes")
                .select()
                .limit(1)
                .execute()
                .value

            return true
        } catch {
            return false
        }
    }

    // MARK: - Auth

    #if DEBUG
    func signInWithDevUser() async throws {
        let session = try await client.auth.signIn(email: devEmail, password: devPassword)
        authUser = session.user
    }
    #endif

    func signIn(email: String, password: String) async throws {
        let session = try await client.auth.signIn(email: email, password: password)
        authUser = session.user
    }

    func signOut() async throws {
        try await client.auth.signOut()
        authUser = nil
        currentUser = nil
    }
}
