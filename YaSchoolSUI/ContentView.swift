import SwiftUI
import TodoItem

struct ContentView: View {
    
    @State var selectedItem: TodoItem? = nil
    @State var items: [TodoItem] = MockData.items
    @State var showAllTask = true
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(items, id: \.id) { item in
                        CellView(todoItem: item) { item in
                            selectedItem = item
                        }
                    }
                } header: {
                    HStack {
                        Text("Выполнено — \(items.filter({ $0.isDone }).count)")
                            .foregroundColor(Color("LabelTertiary"))
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Button {
                            showAllTask.toggle()
                            items = showAllTask ? MockData.items : items.filter({ $0.isDone })
                        } label: {
                            Text(showAllTask ? "Показать" : "Скрыть")
                                .fontWeight(.semibold)
                                .font(.body)
                        }
                        
                    }
                    .padding(.horizontal, -12)
                    .padding(.bottom, 12)
                }
                .textCase(nil)
            }
            .navigationBarTitleDisplayMode(.large)
            .navigationTitle("Мои дела")
        }
        .sheet(item: $selectedItem) { item in
            TaskDetailsView(item: item)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension TodoItem: Identifiable { }

extension TodoItem {
    
    var toggle: Bool {
        self.deadline == nil
    }
    
}

extension Binding where Value == TodoItem? {
    func toNonOptional() -> Binding<TodoItem> {
        return Binding<TodoItem>(
            get: {
                return self.wrappedValue ?? MockData.items.last!
            },
            set: {
                self.wrappedValue = $0
            }
        )
    }
}
