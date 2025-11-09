import SwiftUI

struct RecommendedNextStepsView: View {
    let steps = [
        ("Complete Detailed Assessment", "Get more accurate recommendations"),
        ("Watch Industry Insights", "3 new videos available"),
        ("Explore Required Skills", "Technical & soft skills analysis")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Recommended Next Steps")
                    .font(.title3)
                    .fontWeight(.semibold)
                Spacer()
                Button(action: {}) {
                    Text("View More")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            .padding(.top)
            Divider()
            
            ForEach(steps, id: \.0) { step in
                HStack {
                    VStack(alignment: .leading) {
                        Text(step.0)
                            .font(.subheadline)
                            .fontWeight(.bold)
                        Text(step.1)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 10)
                Divider()
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}