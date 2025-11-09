//import SwiftUI
//
//struct GetNameView: View {
//    @EnvironmentObject private var store: OnboardingStore
//    @State private var name: String = ""
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 24) {
//            Text("We'll use this to personalize your experience.")
//                .foregroundColor(.secondary)
//                .padding(.bottom, 10)
//            
//            VStack(alignment: .leading, spacing: 8) {
//                Text("Name")
//                    .font(.headline)
//                    .foregroundColor(.secondary)
//                
//                TextField("Enter your name", text: $name)
//                    .padding()
//                    .background(Color.gray.opacity(0.1))
//                    .cornerRadius(10)
//                    .onChange(of: name) { newValue in
//                        store.update(field: .name, value: newValue)
//                    }
//            }
//            
//            Spacer()
//        }
//        .padding()
//        .onAppear {
//            name = store.value(for: .name) as? String ?? ""
//        }
//    }
//}
