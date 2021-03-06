import UIKit

class TaskListController: UITableViewController {

    let tasker = Tasker.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        load()
        }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        print("search: \(searchText)")
    }
 
    @IBAction func add(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New Task", message: "Type task below", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { (action) in
            if let textFields = alert.textFields {
                if let item = textFields[0].text {
                    self.tasker.add(task: item)
                    DispatchQueue.main.async {
                        self.save()
                        self.tableView.reloadData()
                    }
                }
            }
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func editMode(_ sender: UIBarButtonItem) {
        self.isEditing = !self.isEditing
        if self.isEditing {
            sender.title = "Done"
        } else {
            sender.title = "Edit"
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasker.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Task", for: indexPath)
        
        if let lable = cell.textLabel {
            let task1 = tasker.tasks[indexPath.row]
            lable.text = task1
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tasker.remove(at: indexPath.row)
            tasker.removeDetails(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            save()
        }
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let task:String = tasker.tasks[fromIndexPath.row]
        let detail:String = tasker.taskDetail[fromIndexPath.row]
        tasker.remove(at: fromIndexPath.row)
        tasker.removeDetails(at: fromIndexPath.row)
        tasker.insert(task: task, at: to.row)
        tasker.insertDetail(detail: detail, at: to.row)
        self.tableView.reloadData()
        save()
    }
   
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "showTask" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                if let navigationController = segue.destination as? UINavigationController {
                    if let TaskController = navigationController.topViewController as? TaskController {
                        tasker.taskID = indexPath.row
                        TaskController.taskID = indexPath.row
                        TaskController.masterView = self
                        let detail = tasker.getDetail(at: indexPath.row)
                        TaskController.setNoteField(t: detail)
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        save()
    }
    
    func save() {
        let savedItems = UserDefaults.standard
        savedItems.set(tasker.tasks, forKey: "tasks")
        savedItems.set(tasker.taskDetail, forKey: "details")
        savedItems.synchronize()
    }
    
    func load() {
        let savedItems = UserDefaults.standard
        if let loadedItems:[String] = savedItems.object(forKey: "tasks") as! [String]? {
            tasker.tasks = loadedItems
            tableView.reloadData()
        }
        if let loadedItems:[String] = savedItems.object(forKey: "details") as! [String]? {
            tasker.taskDetail = loadedItems
        }
        
    }
 
}
