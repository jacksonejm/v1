//import SwiftUI
//
//struct FavoriteSubjectsView: View {
//    @EnvironmentObject private var store: OnboardingStore
//    @State private var selectedSubjects: Set<SchoolSubject> = []
//    
//    var body: some View {
//        VStack(spacing: 20) {
//            Text("Select up to 3 subjects you enjoy the most.")
//                .font(.body)
//                .foregroundColor(.secondary)
//                .padding(.bottom, 10)
//            
//            ScrollView {
//                VStack(spacing: 12) {
//                    ForEach(SchoolSubject.allSubjects) { subject in
//                        SelectionButton(
//                            title: subject.name,
//                            isSelected: selectedSubjects.contains(subject),
//                            action: {
//                                if selectedSubjects.contains(subject) {
//                                    selectedSubjects.remove(subject)
//                                } else if selectedSubjects.count < 3 {
//                                    selectedSubjects.insert(subject)
//                                }
//                                store.update(field: .favoriteSubjects, value: selectedSubjects)
//                            }
//                        )
//                    }
//                }
//            }
//            
//            // Selection Counter
//            VStack(spacing: 8) {
//                HStack(spacing: 12) {
//                    ForEach(0..<3, id: \.self) { index in
//                        Circle()
//                            .fill(index < selectedSubjects.count ? AppColors.primary : Color.gray.opacity(0.2))
//                            .frame(width: 8, height: 8)
//                    }
//                }
//                
//                Text("\(selectedSubjects.count)/3 selected")
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//            }
//            .padding(.top, 10)
//        }
//        .padding()
//        .onAppear {
//            if let saved = store.value(for: .favoriteSubjects) as? Set<SchoolSubject> {
//                selectedSubjects = saved
//            }
//        }
//    }
//}
