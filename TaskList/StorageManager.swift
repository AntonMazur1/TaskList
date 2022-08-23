//
//  StorageManager.swift
//  TaskList
//
//  Created by Клоун on 22.08.2022.
//

import Foundation
import CoreData
import UIKit

class StorageManager {
    static let shared = StorageManager()
    
    private init() {}
    
    var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TaskList")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func save(with name: String, completion: (Task) -> ()) {
        let task = Task(context: persistentContainer.viewContext)
        task.title = name
        do {
            try persistentContainer.viewContext.save()
        } catch let error {
            print(error.localizedDescription)
        }
        completion(task)
    }
    
    func update(with name: String, task: Task, completion: (Task) -> ()) {
        task.title = name
        do {
            try persistentContainer.viewContext.save()
        } catch let error {
            print(error.localizedDescription)
        }
        completion(task)
    }
    
    func removeObject(for indexPath: IndexPath, at tableView: UITableView, with object: Task) {
        tableView.deleteRows(at: [indexPath], with: .automatic)
        persistentContainer.viewContext.delete(object)
        
        do {
            try persistentContainer.viewContext.save()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func fetchData(completion: @escaping(Result<[Task], Error>) -> Void) {
        let fetchRequest = Task.fetchRequest()
        do {
            let taskList = try persistentContainer.viewContext.fetch(fetchRequest)
            completion(.success(taskList))
        } catch let error{
            completion(.failure(error))
        }
    }

    // MARK: - Core Data Saving support
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
