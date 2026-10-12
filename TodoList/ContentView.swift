import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TodoListViewModel()
    @State private var draftTitle = ""
    @FocusState private var isDraftFocused: Bool

    private var trimmedDraft: String {
        draftTitle.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canAddTask: Bool {
        !trimmedDraft.isEmpty
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                composer
                taskContent
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("To-Do")
            .toolbar {
                if !viewModel.tasks.isEmpty {
                    ToolbarItem(placement: .topBarLeading) {
                        EditButton()
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Text(statusText)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private var statusText: String {
        let remaining = viewModel.remainingCount
        if remaining == 0 {
            return "All done"
        }
        return remaining == 1 ? "1 left" : "\(remaining) left"
    }

    private var composer: some View {
        HStack(spacing: 12) {
            Image(systemName: "square.and.pencil")
                .foregroundStyle(.secondary)

            TextField("Add a task", text: $draftTitle)
                .textFieldStyle(.plain)
                .focused($isDraftFocused)
                .submitLabel(.done)
                .onSubmit(addDraft)

            Button(action: addDraft) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .symbolRenderingMode(.hierarchical)
            }
            .buttonStyle(.borderless)
            .disabled(!canAddTask)
            .accessibilityLabel("Add task")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(.background, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.06))
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    @ViewBuilder
    private var taskContent: some View {
        if viewModel.tasks.isEmpty {
            ContentUnavailableView(
                "No Tasks Yet",
                systemImage: "checklist",
                description: Text("Type a task above and tap + to add it.")
            )
        } else {
            List {
                Section {
                    ForEach(viewModel.tasks) { task in
                        TaskRow(task: task) {
                            withAnimation(.snappy) {
                                viewModel.toggleCompletion(for: task.id)
                            }
                        }
                    }
                    .onDelete { offsets in
                        withAnimation {
                            viewModel.deleteTasks(at: offsets)
                        }
                    }
                } footer: {
                    Text("Tap a task to complete it. Swipe left to delete.")
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
        }
    }

    private func addDraft() {
        let title = draftTitle
        let didAdd = withAnimation(.snappy) {
            viewModel.addTask(title: title)
        }
        guard didAdd else { return }
        draftTitle = ""
        isDraftFocused = true
    }
}

private struct TaskRow: View {
    let task: TodoItem
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.title3)
                .foregroundStyle(task.isCompleted ? Color.accentColor : Color.secondary)

            Text(task.title)
                .font(.body)
                .strikethrough(task.isCompleted, color: .secondary)
                .foregroundStyle(task.isCompleted ? Color.secondary : Color.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture(perform: onToggle)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel(task.title)
        .accessibilityValue(task.isCompleted ? "Completed" : "Not completed")
        .accessibilityHint("Toggles completion")
    }
}

#Preview {
    ContentView()
}
