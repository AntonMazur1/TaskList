//
//  TaskListViewController.swift
//  TaskList
//
//  Created by Alexey Efimov on 21.08.2022.
//

import UIKit

class TaskListViewController: UITableViewController {
    
    private let cellID = "task"
    private var taskList: [Task] = []
    private var selectedCell: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        setupNavigationBar()
        fetchData()
    }
    
    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.backgroundColor = UIColor(
            red: 21/255,
            green: 101/255,
            blue: 192/255,
            alpha: 194/255
        )
        
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        navigationController?.navigationBar.tintColor = .white
    }
    
    @objc private func addNewTask() {
        showAlert()
    }
    
    private func fetchData() {
        StorageManager.shared.fetchData { [weak self] result in
            switch result {
            case .success(let tasks):
                self?.taskList = tasks
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func save(_ taskName: String) {
        StorageManager.shared.save(with: taskName) { task in
            self.taskList.append(task)
            self.tableView.insertRows(at: [IndexPath(row: taskList.count - 1, section: 0)], with: .automatic)
        }
    }
}

//MARK: - Table View Data Source
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let object = self.taskList.remove(at: indexPath.row)
            StorageManager.shared.removeObject(for: indexPath, at: tableView, with: object)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCell = indexPath
        showAlert()
    }
}


//MARK: - Setup Alert Controller
extension TaskListViewController {
    private func showAlert() {
        if selectedCell == nil {
            let alert = UIAlertController(title: "Save", message: "Save a new task", preferredStyle: .alert)
            let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] _ in
                guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
                save(task)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
            
            alert.addAction(saveAction)
            alert.addAction(cancelAction)
            alert.addTextField { textField in
                textField.placeholder = "New Task"
            }
            
            present(alert, animated: true)
        } else {
            guard let selectedCell = selectedCell else { return }
            let selectedTask = taskList[selectedCell.row]
            let alertController = UIAlertController(title: "Edit task", message: "Make your changes", preferredStyle: .alert)
            let updateAction = UIAlertAction(title: "Update", style: .default) { action in
                let updatedTask = alertController.textFields?.first?.text
                selectedTask.title = updatedTask
                
                DispatchQueue.main.async { [weak self] in
                    self?.tableView.reloadRows(at: [selectedCell], with: .automatic)
                    StorageManager.shared.update(with: updatedTask ?? "", task: selectedTask) { task in
                        self?.taskList[selectedCell.row] = task
                    }
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
            
            alertController.addAction(cancelAction)
            alertController.addAction(updateAction)
            alertController.addTextField { textField in
                textField.placeholder = "Update your task"
                textField.text = selectedTask.title
            }
            
            present(alertController, animated: true)
        }
    }
}
