//import SwiftUI
//
//struct CurrentStatusView: View {
//    @EnvironmentObject private var store: OnboardingStore
//    @State private var selectedStatus: SelectionOption?
//    
//    private let statusOptions = [
//        SelectionOption(title: "High School Student", iconName: "book.fill"),
//        SelectionOption(title: "College Student", iconName: "graduationcap.fill"),
//        SelectionOption(title: "Recent Graduate", iconName: "doc.fill"),
//        SelectionOption(title: "Working Professional", iconName: "briefcase.fill"),
//        SelectionOption(title: "Career Changer", iconName: "arrow.triangle.swap"),
//        SelectionOption(title: "Taking a Gap Year", iconName: "airplane"),
//        SelectionOption(title: "Other", iconName: "ellipsis.circle.fill")
//    ]
//    
//    @State private var otherText: String = ""
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 20) {
//            Text("This helps us tailor recommendations to your situation.")
//                .foregroundColor(.secondary)
//                .padding(.bottom, 10)
//            
//            ScrollView {
//                VStack(spacing: 12) {
//                    ForEach(statusOptions, id: \.title) { option in
//                        Button(action: {
//                            selectedStatus = option
//                            if option.title != "Other" {
//                                store.update(field: .currentStatus, value: option)
//                            }
//                        }) {
//                            HStack {
//                                Image(systemName: option.iconName)
//                                    .foregroundColor(selectedStatus?.title == option.title ? AppColors.primary : .gray)
//                                    .frame(width: 24, height: 24)
//                                
//                                Text(option.title)
//                                    .foregroundColor(.primary)
//                                    .font(.body)
//                                
//                                Spacer()
//                                
//                                if selectedStatus?.title == option.title {
//                                    Image(systemName: "checkmark.circle.fill")
//                                        .foregroundColor(AppColors.primary)
//                                }
//                            }
//                            .padding()
//                            .background(
//                                RoundedRectangle(cornerRadius: 10)
//                                    .fill(selectedStatus?.title == option.title ? AppColors.primary.opacity(0.1) : Color.gray.opacity(0.1))
//                            )
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 10)
//                                    .stroke(selectedStatus?.title == option.title ? AppColors.primary : Color.gray.opacity(0.3), lineWidth: 1)
//                            )
//                        }
//                    }
//                    
//                    if selectedStatus?.title == "Other" {
//                        TextField("Please specify", text: $otherText)
//                            .padding()
//                            .background(Color.gray.opacity(0.1))
//                            .cornerRadius(10)
//                            .onChange(of: otherText) { newValue in
//                                if !newValue.isEmpty {
//                                    let customOption = SelectionOption(title: newValue, iconName: "ellipsis.circle.fill")
//                                    store.update(field: .currentStatus, value: customOption)
//                                }
//                            }
//                    }
//                }
//            }
//        }
//        .padding()
//        .onAppear {
//            if let savedStatus = store.value(for: .currentStatus) as? SelectionOption {
//                selectedStatus = savedStatus
//                
//                // Check if it's a custom status
//                let standardTitles = statusOptions.map { $0.title }
//                if !standardTitles.contains(savedStatus.title) {
//                    selectedStatus = statusOptions.last // "Other" option
//                    otherText = savedStatus.title
//                }
//            }
//        }
//    }
//}
