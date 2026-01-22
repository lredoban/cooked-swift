import SwiftUI

struct AsyncImageView: View {
    let url: String?
    var placeholder: Image = Image(systemName: "photo")

    var body: some View {
        if let urlString = url, let imageURL = URL(string: urlString) {
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .empty:
                    placeholder
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(.secondary)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    placeholder
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(.secondary)
                @unknown default:
                    placeholder
                }
            }
        } else {
            placeholder
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    AsyncImageView(url: nil)
        .frame(width: 100, height: 100)
}
