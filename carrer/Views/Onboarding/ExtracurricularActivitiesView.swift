//import SwiftUI
//
//struct ExtracurricularActivitiesView: View {
//    @EnvironmentObject private var store: OnboardingStore
//    @State private var selectedActivities: Set<Activity> = []
//    @State private var otherActivity: String = ""
//    
//    var body: some View {
//        VStack(spacing: 20) {
//            Text("Select any activities that interest you.")
//                .font(.body)
//                .foregroundColor(.secondary)
//                .padding(.bottom, 10)
//            
//            ScrollView {
//                VStack(spacing: 12) {
//                    ForEach(Activity.allActivities) { activity in
//                        SelectionButton(
//                            title: activity.name,
//                            isSelected: selectedActivities.contains(activity),
//                            action: {
//                                if selectedActivities.contains(activity) {
//                                    selectedActivities.remove(activity)
//                                    if activity.name == "Other" {
//                                        otherActivity = ""
//                                        store.update(field: .extracurricularOther, value: "")
//                                    }
//                                } else {
//                                    selectedActivities.insert(activity)
//                                }
//                                store.update(field: .extracurriculars, value: selectedActivities)
//                            }
//                        )
//                        
//                        if activity.name == "Other" && selectedActivities.contains(activity) {
//                            TextField("Enter your activity", text: $otherActivity)
//                                .textFieldStyle(RoundedBorderTextFieldStyle())
//                                .padding(.horizontal)
//                                .onChange(of: otherActivity) { newValue in
//                                    store.update(field: .extracurricularOther, value: newValue)
//                                }
//                        }
//                    }
//                }
//            }
//        }
//        .padding()
//        .onAppear {
//            if let saved = store.value(for: .extracurriculars) as? Set<Activity> {
//                selectedActivities = saved
//            }
//            if let savedOther = store.value(for: .extracurricularOther) as? String {
//                otherActivity = savedOther
//            }
//        }
//    }
//}
