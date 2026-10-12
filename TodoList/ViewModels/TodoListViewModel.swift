import Foundation

/// Holds the task list and the actions the screen can perform.
/// Nothing is saved to disk — closing the app clears the list.
final class TodoListViewModel: ObservableObject {
    @Published private(set) var tasks: [TodoItem] = []

    var remainingCount: Int {
        tasks.filter { !$0.isCompleted }.count
    }

    /// Adds a task when the title has visible text. Returns false for blank input.
    @discardableResult
    func addTask(title: String) -> Bool {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return false }

        tasks.append(TodoItem(title: trimmedTitle))
        return true
    }

    /// Flips a task between completed and incomplete.
    func toggleCompletion(for id: UUID) {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else { return }
        tasks[index].isCompleted.toggle()
    }

    /// Removes one task. Unknown ids are ignored.
    func deleteTask(id: UUID) {
        tasks.removeAll { $0.id == id }
    }

    /// Removes the rows the list swipe or Edit button selected.
    func deleteTasks(at offsets: IndexSet) {
        let ids = offsets.map { tasks[$0].id }
        ids.forEach { deleteTask(id: $0) }
    }
}
