//import SwiftUI
//
//struct InterestProfileView: View {
//    @EnvironmentObject private var store: OnboardingStore
//    @State private var selectedInterests: Set<InterestOption> = []
//    
//    private let interestCategories = [
//        InterestOption(name: "Technology & Computing"),
//        InterestOption(name: "Science & Research"),
//        InterestOption(name: "Arts & Design"),
//        InterestOption(name: "Business & Finance"),
//        InterestOption(name: "Healthcare & Medicine"),
//        InterestOption(name: "Education & Teaching"),
//        InterestOption(name: "Engineering"),
//        InterestOption(name: "Communication & Media"),
//        InterestOption(name: "Helping & Social Services"),
//        InterestOption(name: "Nature & Environment"),
//        InterestOption(name: "Sports & Athletics")
//    ]
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 20) {
//            Text("Select up to 5 categories that appeal to you.")
//                .foregroundColor(.secondary)
//                .padding(.bottom, 8)
//            
//            Text("Selected: \(selectedInterests.count)/5")
//                .font(.subheadline)
//                .foregroundColor(selectedInterests.count == 5 ? AppColors.primary : .gray)
//                .padding(.bottom, 16)
//            
//            ScrollView {
//                VStack(spacing: 12) {
//                    ForEach(interestCategories, id: \.id) { interest in
//                        Button(action: {
//                            if selectedInterests.contains(interest) {
//                                selectedInterests.remove(interest)
//                            } else if selectedInterests.count < 5 {
//                                selectedInterests.insert(interest)
//                            }
//                            store.update(field: .interests, value: selectedInterests)
//                        }) {
//                            HStack {
//                                Text(interest.name)
//                                    .foregroundColor(.primary)
//                                    .font(.body)
//                                
//                                Spacer()
//                                
//                                if selectedInterests.contains(interest) {
//                                    Image(systemName: "checkmark.circle.fill")
//                                        .foregroundColor(AppColors.primary)
//                                } else {
//                                    Image(systemName: "circle")
//                                        .foregroundColor(.gray)
//                                }
//                            }
//                            .padding()
//                            .background(
//                                RoundedRectangle(cornerRadius: 10)
//                                    .fill(selectedInterests.contains(interest) ? AppColors.primary.opacity(0.1) : Color.gray.opacity(0.1))
//                            )
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 10)
//                                    .stroke(selectedInterests.contains(interest) ? AppColors.primary : Color.gray.opacity(0.3), lineWidth: 1)
//                            )
//                        }
//                        .disabled(selectedInterests.count >= 5 && !selectedInterests.contains(interest))
//                    }
//                }
//            }
//            
//            if selectedInterests.isEmpty {
//                Text("Please select at least one interest to continue")
//                    .font(.caption)
//                    .foregroundColor(.red)
//                    .padding(.top, 8)
//            }
//        }
//        .padding()
//        .onAppear {
//            if let savedInterests = store.value(for: .interests) as? Set<InterestOption> {
//                selectedInterests = savedInterests
//            }
//        }
//    }
//}
