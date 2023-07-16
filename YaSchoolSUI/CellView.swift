import SwiftUI
import TodoItem
import UIKit

struct CellView: View {
    let todoItem: TodoItem
    let onTap: ((TodoItem) -> Void)
    
    var body: some View {
        HStack(spacing: 12) {
            if !todoItem.text.isEmpty {
                checkBoxImageView
            }
            
            HStack(spacing: 0) {
                Text("")
                priorityImageView(for: todoItem.importance)
                VStack(alignment: .leading, spacing: 4) {
                    if todoItem.text.isEmpty {
                        Text("Новое")
                            .font(.body)
                            .foregroundColor(Color("LabelSecondary"))
                            .lineLimit(1)
                            .padding(.leading, 24)
                            .padding(.vertical, 8)
                    } else {
                        VStack(alignment: .leading, spacing: 0) {
                            Text(todoItem.text)
                                .font(.body)
                                .lineLimit(3)
                            if let deadline = todoItem.deadline {
                                CalendarView(date: deadline)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            Spacer()
            if !todoItem.text.isEmpty {
                arrowImageView
            }
        }
        .background(Color("BackSecondary"))
        .onTapGesture {
            onTap(todoItem)
        }
    }
    
    @ViewBuilder
    func priorityImageView(for importance: Importance?) -> some View {
        switch importance {
        case .low:
            Image("LowPriority")
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)
        case .high:
            Image("HighPriority")
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)
        case .normal, .none:
            EmptyView()
                .scaledToFit()
                .frame(width: 16, height: 16)
        }
    }
    
    private var checkBoxImageView: some View {
        Image(uiImage: (todoItem.isDone != true
                        ? UIImage(named: "Prop=off")?.withTintColor(UIColor(named: "Check") ?? .gray)
                        : UIImage(named: "Prop=on")) ?? .checkmark
        )
        .resizable()
        .frame(width: 24, height: 24)
    }
    
    private var arrowImageView: some View {
        Image("Mode=Light")
            .resizable()
            .scaledToFit()
            .frame(width: 12, height: 12)
    }
    
    private struct CalendarView: View {
        let date: Date
        
        var body: some View {
            HStack(spacing: 4) {
                calendarImageView
                    .frame(width: 14, height: 14)
                Text(formatDate(date))
                    .font(.subheadline)
                    .foregroundColor(Color("LabelTertiary"))
            }
        }
        
        private var calendarImageView: some View {
            Image("Calendar")
                .resizable()
                .frame(width: 14, height: 14)
                .foregroundColor(Color("LabelTertiary"))
        }
        
        private func formatDate(_ date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMMM"
            return formatter.string(from: date)
        }
    }
}

struct CustomTableViewCell_Previews: PreviewProvider {
    static var previews: some View {
        List {
            ForEach(MockData.items, id: \.id) { item in
                CellView(todoItem: item, onTap: { _ in })
            }
        }
    }
}
