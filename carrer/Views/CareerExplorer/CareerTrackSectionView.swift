import SwiftUI

struct CareerTrackSectionView: View {
    let careerTracks: [CareerTrack]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Career Track Progress")
                    .font(.title3)
                    .fontWeight(.semibold)
                Spacer()
                Button(action: {}) {
                    Text("Add Track")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            
            ForEach(careerTracks) { track in
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(track.title)
                                .font(.headline)
                            Text("\(track.match)% Match with Your Profile")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text("\(track.progress)% Complete")
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    
                    // Progress Bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .frame(width: geometry.size.width, height: 8)
                                .opacity(0.1)
                                .foregroundColor(.blue)
                            
                            Rectangle()
                                .frame(width: min(CGFloat(track.progress) * geometry.size.width / 100, geometry.size.width), height: 8)
                                .foregroundColor(.blue)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                    .frame(height: 8)
                    
                    HStack {
                        Text("Salary: \(track.salary)")
                        Spacer()
                        Text("Education: \(track.education)")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
            }
        }
    }
}