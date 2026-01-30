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
                        .foregroundStyle(Color.dopamineSecondary)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    placeholder
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(Color.dopamineSecondary)
                @unknown default:
                    placeholder
                }
            }
        } else {
            placeholder
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(Color.dopamineSecondary)
        }
    }
}

#Preview {
    AsyncImageView(url: nil)
        .frame(width: 100, height: 100)
        .background(Color.dopamineSurface)
}
