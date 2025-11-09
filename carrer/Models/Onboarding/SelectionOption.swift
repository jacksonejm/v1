import Foundation

struct SelectionOption: Hashable, Identifiable {
    let title: String
    let iconName: String
    var id: String { title }

    static let howDidYouHearOptions: [SelectionOption] = [
        SelectionOption(title: "Friend or Family", iconName: "person.2.fill"),
        SelectionOption(title: "Social Media", iconName: "network"),
        SelectionOption(title: "Online Ad", iconName: "megaphone.fill"),
        SelectionOption(title: "School or Teacher", iconName: "book.fill"),
        SelectionOption(title: "Other", iconName: "ellipsis.circle.fill")
    ]
}