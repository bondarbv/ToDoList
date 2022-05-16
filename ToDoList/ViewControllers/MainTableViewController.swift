//
//  MainTableViewController.swift
//  ToDoList
//
//  Created by Bohdan on 15.05.2022.
//

import UIKit
import CoreData


class MainTableViewController: UITableViewController {
    
    var tasks: [Task] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let context = getContext()
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        let sortDecriptor = NSSortDescriptor(key: "title", ascending: false)
        fetchRequest.sortDescriptors = [sortDecriptor]
        
        do {
            tasks = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        isLeftBarButtonEnabled()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "To Do List"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTask))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteTask))
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: CustomTableViewCell.id)
    }
    
    @objc private func addTask() {
        addtaskAlertController(title: "New Task", message: "Please add a new task", style: .alert)
    }
    
    @objc private func deleteTask() {
        deleteTaskAlertController(title: "Delet all tasks", message: "If you want to delete all tasks, please type 'Delete' in the text field", style: .alert)
    }

    private func saveTask(withTitle title: String) {
        let context = getContext()
        guard let entity = NSEntityDescription.entity(forEntityName: "Task", in: context) else { return }
        let taskObject = Task(entity: entity, insertInto: context)
        taskObject.title = title
        do {
            try context.save()
            tasks.insert(taskObject, at: 0)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
    }
    
    private func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
        
    }
    
    private func addtaskAlertController(title: String, message: String, style: UIAlertController.Style) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        let addingTask = UIAlertAction(title: "Save", style: .default) { _ in
            let maxLenght = 70
            guard let textField = alertController.textFields?.first else { return }
            guard let lengthLimit = textField.text?.count else { return }
            guard let newTaskTitle = textField.text else { return }
            if newTaskTitle != "" && lengthLimit < maxLenght {
                self.saveTask(withTitle: newTaskTitle)
                self.tableView.reloadData()
                self.isLeftBarButtonEnabled()
            } else if lengthLimit >= maxLenght {
                let errorAlertController = UIAlertController(title: "Error", message: "Task's max length is \(maxLenght)", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default)
                errorAlertController.addAction(ok)
                self.present(errorAlertController, animated: true)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addTextField { _ in }
        alertController.addAction(cancelAction)
        alertController.addAction(addingTask)
        present(alertController, animated: true)
    }
    
    private func deleteTaskAlertController(title: String, message: String, style: UIAlertController.Style) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        let ok = UIAlertAction(title: "OK", style: .cancel)
        let deletingTask = UIAlertAction(title: "Delete", style: .destructive) { _ in
            let textField = alertController.textFields?.first
            textField?.placeholder = "Delete"
            if textField?.text == "Delete" {
                let context = self.getContext()
                let fetchRequeest: NSFetchRequest<Task> = Task.fetchRequest()
                if let objects = try? context.fetch(fetchRequeest) {
                    for object in objects {
                        context.delete(object)
                    }
                    do {
                        try context.save()
                        self.tasks.removeAll()
                        self.tableView.reloadData()
                        self.isLeftBarButtonEnabled()
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                    let successAlertController = UIAlertController(title: "Completed", message: "All your tasks are deleted", preferredStyle: .alert)
                    successAlertController.addAction(ok)
                    self.present(successAlertController, animated: true)
                }
            } else {
                let errorAlertController = UIAlertController(title: "Error", message: "Wrong value", preferredStyle: .alert)
                errorAlertController.addAction(ok)
                self.present(errorAlertController, animated: true)
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addTextField { _ in }
        alertController.addAction(deletingTask)
        alertController.addAction(cancel)
        present(alertController, animated: true)
    }
    
    private func isLeftBarButtonEnabled() {
        if tasks.count == 0 {
            navigationItem.leftBarButtonItem?.isEnabled = false
        } else if tasks.count > 0 {
            navigationItem.leftBarButtonItem?.isEnabled = true
        }
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: CustomTableViewCell.id, for: indexPath) as? CustomTableViewCell {
            let task = tasks[indexPath.row]
            cell.label.text = task.title
            cell.selectionStyle = .none
            cell.button.addTarget(self, action: #selector(test(sender:)), for: .touchUpInside)
            return cell
        }
        return UITableViewCell()
    }
    
    @objc func test(sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
        } else {
            sender.isSelected = true
        }
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Tasks"
        }
        return ""
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            let context = self.getContext()
            let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
            if let object = try? context.fetch(fetchRequest) {
                context.delete(object[indexPath.row])
                tasks.remove(at: indexPath.row)
                do {
                    try context.save()
                    self.isLeftBarButtonEnabled()
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        }
    }
}
