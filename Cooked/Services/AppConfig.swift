import Foundation

enum AppConfig {
    static var supabaseURL: URL {
        guard let urlString = Bundle.main.infoDictionary?["SUPABASE_URL"] as? String,
              !urlString.isEmpty,
              urlString != "https://your-project-id.supabase.co",
              let url = URL(string: urlString) else {
            // Return a placeholder URL for development
            // The app will show an error when trying to connect
            return URL(string: "https://placeholder.supabase.co")!
        }
        return url
    }

    static var supabaseAnonKey: String {
        guard let key = Bundle.main.infoDictionary?["SUPABASE_ANON_KEY"] as? String,
              !key.isEmpty,
              key != "your-anon-key-here" else {
            return "placeholder-key"
        }
        return key
    }

    static var backendURL: URL {
        guard let urlString = Bundle.main.infoDictionary?["BACKEND_URL"] as? String,
              !urlString.isEmpty,
              let url = URL(string: urlString) else {
            return URL(string: "http://localhost:3000")!
        }
        return url
    }

    static var revenueCatAPIKey: String {
        guard let key = Bundle.main.infoDictionary?["REVENUECAT_API_KEY"] as? String,
              !key.isEmpty,
              key != "appl_your_api_key" else {
            return "placeholder-key"
        }
        return key
    }

    static var isConfigured: Bool {
        let urlString = Bundle.main.infoDictionary?["SUPABASE_URL"] as? String ?? ""
        return !urlString.isEmpty && !urlString.contains("your-project-id")
    }
}
