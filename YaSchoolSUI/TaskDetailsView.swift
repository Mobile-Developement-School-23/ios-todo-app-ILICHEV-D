import Foundation
import SwiftUI
import TodoItem

struct TaskDetailsView: View {
    
    @Environment(\.dismiss) var dismiss
    
    var viewModel: TodoItem
    @State var date: Date?
    @State var toggle: Bool
    @State var importance: Int
    
    init(item: TodoItem) {
        self.viewModel = item
        _date = State(initialValue: item.deadline)
        _toggle = State(initialValue: item.deadline != nil)
        _importance = State(initialValue: item.importance.index)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(viewModel.text)
                        .font(.system(size: 17))
                        .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
                        .frame(maxWidth: .infinity, minHeight: 120, alignment: .topLeading)
                        .background(Color("BackSecondary"))
                        .multilineTextAlignment(.leading)
                        .cornerRadius(16)
                        .overlay(placeholderLabel, alignment: .topLeading)
                    
                    VStack(spacing: 0) {
                        firstLine
                        Divider()
                        secondLine
                        
                        if viewModel.deadline != nil {
                            Divider()
                            thirdLine
                        }
                    }
                    .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 12))
                    .background(Color("BackSecondary"))
                    .cornerRadius(16)
                    
                    Button("Удалить") { }
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56, alignment: .center)
                        .disabled(true)
                        .background(Color("BackSecondary"))
                        .cornerRadius(16)
                }
                .padding()
            }
            .background(Color("Back"))
            .navigationBarTitle("Дело")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Отменить") {
                    dismiss()
                },
                trailing: Button("Сохранить") { }
                    .disabled(true)
            )
        }
    }
    
    
    private var firstLine: some View {
        HStack {
            Text("Важность")
            Spacer()
            
            Picker("", selection: $importance) {
                Image(uiImage: (UIImage(named: "LowPriority")?.withTintColor(.gray, renderingMode: .alwaysOriginal))!)
                    .tag(0)
                Text("нет")
                    .tag(1)
                    .frame(width: 100)
                Image("HighPriority")
                    .tag(2)
            }
            .pickerStyle(.segmented)
            .disabled(true)
            .frame(width: 147)
        }
        .frame(height: 56)
    }
    
    private var secondLine: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                Text("Сделать до")
                if let text = formatter() {
                    Text(text)
                        .foregroundColor(.blue)
                        .font(.system(size: 13))
                        .padding(.top, 2)
                }
                Spacer()
            }
            Spacer()
            Toggle("", isOn: $toggle)
                .disabled(true)
        }
        .frame(height: 56)
    }
    
    private var thirdLine: some View {
        DatePicker(
            "",
            selection: $date.toNonOptional(),
            in: Date()...,
            displayedComponents: .date
        )
        .disabled(true)
        .datePickerStyle(.graphical)
        .padding(.horizontal, -6)
    }
    
    private var placeholderLabel: some View {
        Text("Что надо сделать?")
            .font(.system(size: 17))
            .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
            .foregroundColor(.secondary)
            .opacity(viewModel.text.isEmpty ? 1 : 0)
    }
    
    private func formatter() -> String? {
        if let dealine = viewModel.deadline {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: dealine)
        } else {
            return nil
        }
    }
}

extension Importance {
    
    var index: Int {
        switch self {
        case .low:
            return 0
        case .normal:
            return 1
        case .high:
            return 2
        }
    }
    
}

struct TaskDetailsView_Previews: PreviewProvider {
    
    
    static var previews: some View {
        TaskDetailsView(item: MockData.items.last!)
    }
    
}


private extension Binding where Value == Date? {
    
    func toNonOptional() -> Binding<Date> {
        return Binding<Date>(
            get: {
                return self.wrappedValue ?? Date()
            },
            set: {
                self.wrappedValue = $0
            }
        )
    }
    
}

