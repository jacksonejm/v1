import SwiftUI

struct JobCard: View {
    let job: Job

    var body: some View {
        let screenWidth = UIScreen.main.bounds.width
        VStack {
            Text(job.title)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding()
        }
        .frame(width: screenWidth * 0.8, height: 150)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}