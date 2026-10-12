import XCTest
@testable import TodoList

final class TodoListTests: XCTestCase {
    func testAddTask() {
        let viewModel = TodoListViewModel()

        let didAdd = viewModel.addTask(title: "Buy groceries")

        XCTAssertTrue(didAdd)
        XCTAssertEqual(viewModel.tasks.count, 1)
        XCTAssertEqual(viewModel.tasks[0].title, "Buy groceries")
        XCTAssertFalse(viewModel.tasks[0].isCompleted)

        // Blank titles, including whitespace, are rejected.
        XCTAssertFalse(viewModel.addTask(title: "   "))
        XCTAssertEqual(viewModel.tasks.count, 1)
    }

    func testCompleteTask() {
        let viewModel = TodoListViewModel()
        viewModel.addTask(title: "Walk the dog")
        let taskID = viewModel.tasks[0].id

        viewModel.toggleCompletion(for: taskID)
        XCTAssertTrue(viewModel.tasks[0].isCompleted)

        viewModel.toggleCompletion(for: taskID)
        XCTAssertFalse(viewModel.tasks[0].isCompleted)
    }

    func testDeleteTask() {
        let viewModel = TodoListViewModel()
        viewModel.addTask(title: "Read a chapter")
        viewModel.addTask(title: "Write unit tests")
        let firstID = viewModel.tasks[0].id

        viewModel.deleteTask(id: firstID)

        XCTAssertEqual(viewModel.tasks.count, 1)
        XCTAssertEqual(viewModel.tasks[0].title, "Write unit tests")
        XCTAssertFalse(viewModel.tasks.contains { $0.id == firstID })
    }
}
