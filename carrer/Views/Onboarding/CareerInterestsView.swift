//import SwiftUI
//
//struct CareerInterestsView: View {
//    @EnvironmentObject private var store: OnboardingStore
//    @State private var selectedCareers: Set<Career> = []
//    @State private var otherCareer: String = ""
//    @State private var showCustomCareerField = false
//    
//    var body: some View {
//        VStack(spacing: 20) {
//            Text("Select or type any careers or jobs that excite you.")
//                .font(.body)
//                .foregroundColor(.secondary)
//                .padding(.bottom, 10)
//            
//            ScrollView {
//                VStack(spacing: 12) {
//                    ForEach(Career.suggestedCareers) { career in
//                        SelectionButton(
//                            title: career.name,
//                            isSelected: selectedCareers.contains(career),
//                            action: {
//                                if selectedCareers.contains(career) {
//                                    selectedCareers.remove(career)
//                                    if career.name == "Other" {
//                                        otherCareer = ""
//                                        showCustomCareerField = false
//                                        store.update(field: .careerInterestsOther, value: "")
//                                    }
//                                } else {
//                                    selectedCareers.insert(career)
//                                    if career.name == "Other" {
//                                        showCustomCareerField = true
//                                    }
//                                }
//                                store.update(field: .careerInterests, value: selectedCareers)
//                            }
//                        )
//                    }
//                    
//                    if showCustomCareerField {
//                        VStack(alignment: .leading, spacing: 8) {
//                            Text("What career interests you?")
//                                .font(.subheadline)
//                                .foregroundColor(.secondary)
//                            
//                            TextField("Enter career", text: $otherCareer)
//                                .textFieldStyle(RoundedBorderTextFieldStyle())
//                                .onChange(of: otherCareer) { newValue in
//                                    store.update(field: .careerInterestsOther, value: newValue)
//                                }
//                        }
//                        .padding(.horizontal)
//                    }
//                }
//            }
//        }
//        .padding()
//        .onAppear {
//            if let saved = store.value(for: .careerInterests) as? Set<Career> {
//                selectedCareers = saved
//                
//                // Check if "Other" is selected
//                if selectedCareers.contains(where: { $0.name == "Other" }) {
//                    showCustomCareerField = true
//                }
//            }
//            if let savedOther = store.value(for: .careerInterestsOther) as? String {
//                otherCareer = savedOther
//            }
//        }
//    }
//}
