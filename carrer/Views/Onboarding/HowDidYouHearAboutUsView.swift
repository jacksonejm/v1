//import SwiftUI
//
//struct HowDidYouHearAboutUsView: View {
//    @EnvironmentObject private var store: OnboardingStore
//    @State private var selection: SelectionOption?
//    @State private var otherText: String = ""
//    
//    // Options for how they heard about us
//    private let options = [
//        SelectionOption(title: "Friend or Family", iconName: "person.2.fill"),
//        SelectionOption(title: "School or Teacher", iconName: "graduationcap.fill"),
//        SelectionOption(title: "Social Media", iconName: "bubble.left.fill"),
//        SelectionOption(title: "Search Engine", iconName: "magnifyingglass"),
//        SelectionOption(title: "App Store", iconName: "app.fill"),
//        SelectionOption(title: "Advertisement", iconName: "megaphone.fill"),
//        SelectionOption(title: "Other", iconName: "ellipsis.circle.fill")
//    ]
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 20) {
//            Text("We'd love to know how you discovered MyPath.")
//                .foregroundColor(.secondary)
//                .padding(.bottom, 24)
//            
//            VStack(spacing: 0) {
//                ForEach(options, id: \.title) { opt in
//                    Button(action: {
//                        withAnimation(.easeInOut(duration: 0.2)) {
//                            selection = opt
//                            if opt.title != "Other" {
//                                store.update(field: .howDidYouHearAboutUs, value: opt)
//                            } else {
//                                // If other is selected but no text, don't update yet
//                                if !otherText.isEmpty {
//                                    let customOption = SelectionOption(title: otherText, iconName: "ellipsis.circle.fill")
//                                    store.update(field: .howDidYouHearAboutUs, value: customOption)
//                                }
//                            }
//                        }
//                    }) {
//                        HStack {
//                            Image(systemName: opt.iconName)
//                                .foregroundColor(selection?.title == opt.title ? AppColors.primary : .gray)
//                                .frame(width: 24, height: 24)
//                            
//                            Text(opt.title)
//                                .foregroundColor(.primary)
//                                .font(.body)
//                            
//                            Spacer()
//                            
//                            if selection?.title == opt.title {
//                                Image(systemName: "checkmark.circle.fill")
//                                    .foregroundColor(AppColors.primary)
//                            }
//                        }
//                        .padding()
//                        .background(
//                            RoundedRectangle(cornerRadius: 10)
//                                .fill(selection?.title == opt.title ? AppColors.primary.opacity(0.1) : Color.gray.opacity(0.1))
//                        )
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 10)
//                                .stroke(selection?.title == opt.title ? AppColors.primary : Color.gray.opacity(0.3), lineWidth: 1)
//                        )
//                    }
//                    .padding(.bottom, selection?.title == "Other" && opt.title == "Other" ? 0 : 12)
//                    
//                    // Insert inline TextField under "Other"
//                    if opt.title == "Other", selection?.title == "Other" {
//                        TextField("Please specify…", text: $otherText)
//                            .font(.body)
//                            .padding(.vertical, 12)
//                            .padding(.leading, 16)
//                            .padding(.trailing, 16)
//                            .overlay(
//                                Rectangle()
//                                    .frame(height: 1)
//                                    .foregroundColor(.gray.opacity(0.3)),
//                                alignment: .bottom
//                            )
//                            .onChange(of: otherText) { newValue in
//                                if !newValue.isEmpty {
//                                    let customOption = SelectionOption(title: newValue, iconName: "ellipsis.circle.fill")
//                                    store.update(field: .howDidYouHearAboutUs, value: customOption)
//                                }
//                            }
//                            .padding(.bottom, 12)
//                    }
//                }
//            }
//            .background(Color.white)
//            .cornerRadius(10)
//        }
//        .padding()
//        .onAppear {
//            // Handle loading existing data
//            if let savedValue = store.value(for: .howDidYouHearAboutUs) as? SelectionOption {
//                selection = savedValue
//                if savedValue.title != "Friend or Family" &&
//                   savedValue.title != "School or Teacher" &&
//                   savedValue.title != "Social Media" &&
//                   savedValue.title != "Search Engine" &&
//                   savedValue.title != "App Store" &&
//                   savedValue.title != "Advertisement" {
//                    selection = options.last // The "Other" option
//                    otherText = savedValue.title
//                }
//            }
//        }
//    }
//}
