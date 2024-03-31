//
//  StorageManager.swift
//  TaskList
//
//  Created by Никита Тыщенко on 01.04.2024.
//

import CoreData

final class StorageManager {
    static let shared = StorageManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TaskList")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    private var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

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
    
    func fetchData() -> [ToDoTask] {
        let fetchRequest = ToDoTask.fetchRequest()
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print(error)
            return []
        }
    }
    
    func addTask(taskList: inout [ToDoTask], taskName: String) {
        let task = ToDoTask(context: context)
        task.title = taskName
        taskList.append(task)
        saveContext()
    }
    
    func editTask(task: ToDoTask, newTitle: String) {
        task.title = newTitle
        saveContext()
    }
    
    func daleteTask(task: ToDoTask) {
        context.delete(task)
        saveContext()
    }
    
    private init() {}
}
