import SwiftUI
import Foundation

struct JobCarousel: View {
    let jobs: [Job]
    @Binding var selectedJob: Job? // Binding to set the selected job when tapped

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(jobs) { job in
                    JobCard(job: job)
                        .onTapGesture {
                            selectedJob = job
                        }
                }
            }
        }
        .frame(height: 150)
    }
}