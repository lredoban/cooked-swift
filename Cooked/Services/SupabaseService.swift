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

    private init() {
        client = SupabaseClient(
            supabaseURL: AppConfig.supabaseURL,
            supabaseKey: AppConfig.supabaseAnonKey,
            options: .init(
                auth: .init(emitLocalSessionAsInitialSession: true)
            )
        )
    }

    // MARK: - Initialization

    /// Initialize Supabase with anonymous auth
    /// Returns true if successfully authenticated (restored session or new anonymous sign-in)
    func initialize() async -> Bool {
        guard AppConfig.isConfigured else {
            print("[Cooked] Supabase not configured")
            return false
        }

        // Try to restore existing session first
        do {
            let session = try await client.auth.session
            authUser = session.user
            print("[Cooked] Restored existing session for user: \(session.user.id)")
            return true
        } catch {
            // No existing session, sign in anonymously
            print("[Cooked] No existing session, signing in anonymously...")
            return await signInAnonymously()
        }
    }

    // MARK: - Anonymous Auth

    /// Sign in anonymously - creates a new anonymous user
    func signInAnonymously() async -> Bool {
        do {
            let session = try await client.auth.signInAnonymously()
            authUser = session.user
            print("[Cooked] Anonymous sign-in successful. User ID: \(session.user.id)")
            return true
        } catch {
            print("[Cooked] Anonymous sign-in failed: \(error)")
            return false
        }
    }

    // MARK: - Standard Auth (for future account linking)

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
