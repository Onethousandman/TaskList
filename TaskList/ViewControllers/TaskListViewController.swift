//
//  ViewController.swift
//  TaskList
//
//  Created by Alexey Efimov on 28.03.2024.
//

import UIKit

enum typeAction {
    case add
    case edit
}

final class TaskListViewController: UITableViewController {
    private let storageManager = StorageManager.shared
    private let cellID = "task"
    private var taskList: [ToDoTask] = []
    private var selectedIndexPath: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        taskList = storageManager.fetchData()
    }
    
    @objc private func addNewTask() {
        showAlert(withTitle: "New Task", andMessage: "What do you want to do?", type: .add)
    }
    
    private func showAlert(
        withTitle title: String,
        andMessage message: String,
        type: typeAction,
        task: ToDoTask = ToDoTask()
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { [unowned self] _ in
            guard let inputText = alert.textFields?.first?.text, !inputText.isEmpty else { return }
            switch type {
            case .add:
                storageManager.addTask(taskList: &taskList, taskName: inputText)
                addRow()
            case .edit:
                guard let selectedIndexPath = selectedIndexPath else { return }
                storageManager.editTask(task: task, newTitle: inputText)
                tableView.reloadRows(at: [selectedIndexPath], with: .automatic)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        alert.addTextField { [unowned self] textField in
            guard let selectedIndexPath = selectedIndexPath else { return }
            switch type {
            case .add:
                textField.placeholder = "New Task"
            case .edit:
                textField.text = taskList[selectedIndexPath.row].title
            }
        }
        present(alert, animated: true)
    }
    
    private func addRow() {
        let indexPath = IndexPath(row: taskList.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
}

// MARK: - UITableViewDataSource
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        if editingStyle == .delete {
            let task = taskList[indexPath.row]
            taskList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            storageManager.daleteTask(task: task)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTask = taskList[indexPath.row]
        selectedIndexPath = indexPath
        showAlert(
            withTitle: "Edit Task",
            andMessage: "What do you want to do?",
            type: .edit,
            task: selectedTask
        )
    }
}

// MARK: - Setup UI
private extension TaskListViewController {
    func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Navigation bar appearance
        let navBarAppearance = UINavigationBarAppearance()
        
        navBarAppearance.backgroundColor = .milkBlue
        
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        // Add button to navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        
        navigationController?.navigationBar.tintColor = .white
    }
}
