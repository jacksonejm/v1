//import SwiftUI
//
//struct StudentLevelView: View {
//    @EnvironmentObject private var store: OnboardingStore
//    @State private var selectedLevel: SelectionOption?
//    
//    private let levelOptions = [
//        SelectionOption(title: "High School Freshman", iconName: "1.circle.fill"),
//        SelectionOption(title: "High School Sophomore", iconName: "2.circle.fill"),
//        SelectionOption(title: "High School Junior", iconName: "3.circle.fill"),
//        SelectionOption(title: "High School Senior", iconName: "4.circle.fill"),
//        SelectionOption(title: "College Freshman", iconName: "c.circle.fill"),
//        SelectionOption(title: "College Sophomore", iconName: "c.circle.fill"),
//        SelectionOption(title: "College Junior", iconName: "c.circle.fill"),
//        SelectionOption(title: "College Senior", iconName: "c.circle.fill"),
//        SelectionOption(title: "Graduate Student", iconName: "g.circle.fill"),
//        SelectionOption(title: "Not Currently a Student", iconName: "person.fill")
//    ]
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 20) {
//            Text("This helps us recommend appropriate resources and opportunities.")
//                .foregroundColor(.secondary)
//                .padding(.bottom, 10)
//            
//            ScrollView {
//                VStack(spacing: 12) {
//                    ForEach(levelOptions, id: \.title) { option in
//                        Button(action: {
//                            selectedLevel = option
//                            store.update(field: .studentLevel, value: option)
//                        }) {
//                            HStack {
//                                Image(systemName: option.iconName)
//                                    .foregroundColor(selectedLevel?.title == option.title ? AppColors.primary : .gray)
//                                    .frame(width: 24, height: 24)
//                                
//                                Text(option.title)
//                                    .foregroundColor(.primary)
//                                    .font(.body)
//                                
//                                Spacer()
//                                
//                                if selectedLevel?.title == option.title {
//                                    Image(systemName: "checkmark.circle.fill")
//                                        .foregroundColor(AppColors.primary)
//                                }
//                            }
//                            .padding()
//                            .background(
//                                RoundedRectangle(cornerRadius: 10)
//                                    .fill(selectedLevel?.title == option.title ? AppColors.primary.opacity(0.1) : Color.gray.opacity(0.1))
//                            )
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 10)
//                                    .stroke(selectedLevel?.title == option.title ? AppColors.primary : Color.gray.opacity(0.3), lineWidth: 1)
//                            )
//                        }
//                    }
//                }
//            }
//        }
//        .padding()
//        .onAppear {
//            selectedLevel = store.value(for: .studentLevel) as? SelectionOption
//        }
//    }
//}
