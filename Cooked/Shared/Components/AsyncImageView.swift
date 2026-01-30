import SwiftUI

struct AsyncImageView: View {
    let url: String?
    var placeholder: Image = Image(systemName: "photo")

    var body: some View {
        if let urlString = url, let imageURL = URL(string: urlString) {
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .empty:
                    placeholderView
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    placeholderView
                @unknown default:
                    placeholderView
                }
            }
        } else {
            placeholderView
        }
    }

    private var placeholderView: some View {
        ZStack {
            Color.curatedBeige
            placeholder
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(Color.curatedWarmGrey)
                .frame(width: 32, height: 32)
        }
    }
}

#Preview {
    AsyncImageView(url: nil)
        .frame(width: 100, height: 100)
        .cornerRadius(12)
}
