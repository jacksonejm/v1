import SwiftUI

struct JobMatchCard: View {
    let job: Job
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(job.title)
                        .font(.headline)
                    Text(job.focus)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                ZStack {
                    Circle()
                        .stroke(Color.blue, lineWidth: 3)
                        .frame(width: 40, height: 40)
                    
                    Text("\(job.matchPercentage)%")
                        .font(.system(size: 12))
                        .fontWeight(.bold)
                }
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Salary")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(job.salaryRange)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Growth")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(job.growth)
                        .font(.caption)
                        .fontWeight(.medium)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}