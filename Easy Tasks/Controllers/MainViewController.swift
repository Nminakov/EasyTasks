//
//  ViewController.swift
//  Homework Tasks
//
//  Created by Nikita on 10.10.2020.
//

import UIKit
import UserNotifications

class MainViewController: UIViewController {
    
    private let notificationCenter = UNUserNotificationCenter.current()
    private let identifier = "studio.devlav.HomeworkTasks.notification"
    
    var lessons: [LessonModel] = [] {
        didSet {
            collectionView.isHidden = lessons.isEmpty
            taskLabel.isHidden = lessons.isEmpty
            addTaskButton.isHidden = lessons.isEmpty
            tableView.isHidden = lessons.isEmpty
        }
    }
    let mainColor = #colorLiteral(red: 0.9549382329, green: 0.9729396701, blue: 0.9871523976, alpha: 1)

    private var currentLesson: LessonModel?
    private var currentIndexPath = IndexPath(item: 0, section: 0)
    
    @IBOutlet var addLessonButton: UIButton! {
        didSet {
            self.configureButton(button: addLessonButton)
        }
    }
    @IBOutlet var addTaskButton: UIButton! {
        didSet {
            self.configureButton(button: addTaskButton)
        }
    }

    @IBOutlet weak var borderRoundView: UIView! {
        didSet {
            borderRoundView.layer.cornerRadius = 30
            borderRoundView.layer.borderWidth = 1
            borderRoundView.layer.borderColor = #colorLiteral(red: 0.662745098, green: 0.7333333333, blue: 0.7882352941, alpha: 1).cgColor
            
            borderRoundView.backgroundColor = .clear
        }
    }
    @IBOutlet weak var insideRoundView: UIView! {
        didSet {
            insideRoundView.layer.cornerRadius = 25
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tasksForTodayLabel: UILabel!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.separatorStyle = .none
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchLessons()
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        collectionView.collectionViewLayout = flowLayout
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        
        view.backgroundColor = mainColor
        collectionView.backgroundColor = mainColor
        tableView.backgroundColor = mainColor
        
        titleLabel.text = "Здравствуйте!"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createTask", let taskController = segue.destination as? CreateTaskViewController {
            taskController.lessonIdentifier = currentLesson?.id
            taskController.closeHandler = {
                self.fetchLessons()
            }
        }
    }
    
    private func openForEdit(with task: TaskModel) {
        if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "createTaskController") as? CreateTaskViewController {
            controller.task = task
            controller.mode = .edit
            controller.closeHandler = {
                self.fetchLessons()
            }
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    @IBAction func addLessonTapped(_ sender: UIButton) {
        let helper = LessonInputViewHelper(with: view)
        helper.show()
        helper.resultHandler = { color, name in
            self.createLesson(with: name, and: color.hexStringFromColor())
        }
    }
    
    private func configureButton(button: UIButton) {
        button.layer.cornerRadius = 12
        
        button.layer.shadowColor = UIColor.gray.cgColor
        button.layer.shadowOffset = .zero
        button.layer.shadowRadius = 8
        button.layer.shadowOpacity = 0.3
    }
}

extension MainViewController {
    
    private func createLesson(with name: String, and hexColor: String) {
        let lesson = Lesson()
        lesson.name = name
        lesson.color = hexColor
        lesson.addWithPrimaryKey()
        
        fetchLessons()
    }
    
    private func fetchLessons() {
        guard
            let objects = RealmObjects.objects(type: Lesson.self) else {
            return
        }
        let preparedLessons: [LessonModel] = objects.map {
            return LessonModel(id: $0.id, iconSymbol: $0.iconSymbol, name: $0.name, color: $0.color, tasks: $0.tasks.map { task in
                return TaskModel(id: task.id, name: task.name, deadline: task.deadline, notificationTime: task.notificationTime, isRemind: task.isRemind, isFinished: task.isFinished)
            })
        }
        
        lessons = preparedLessons
        
        if !lessons.isEmpty {
            currentLesson = lessons[currentIndexPath.item]
        }
        else {
            currentLesson = nil
        }
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.tableView.reloadData()
        }
        
        self.recalculateNotifications()
        self.setData()
    }
    
    private func delete(for task: TaskModel) {
        guard
            let object = RealmObjects.objects(type: Task.self)?.filter("id = '\(task.id)'").first else {
            return
        }
        object.delete()
        fetchLessons()
    }
    
    private func delete(for lesson: String) {
        guard
            let object = RealmObjects.objects(type: Lesson.self)?.filter("id = '\(lesson)'").first else {
            return
        }
        object.tasks.forEach { task in
            task.delete()
        }
        
        object.delete()
        currentIndexPath = IndexPath(item: 0, section: 0)
        fetchLessons()
    }
    
    private func toggleTask(for task: TaskModel) {
        guard
            let object = RealmObjects.objects(type: Task.self)?.filter("id = '\(task.id)'").first else {
            return
        }
        object.update {
            object.isFinished.toggle()
        }
        fetchLessons()
    }
}

extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lessons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! LessonCollectionViewCell
        cell.configure(for: lessons[indexPath.item])
        cell.deleteHandler = { lessonId in
            self.delete(for: lessonId)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? LessonCollectionViewCell {
            cell.roundView.animateTap {
                self.currentIndexPath = indexPath
                self.currentLesson = self.lessons[indexPath.item]
                self.tableView.reloadData()
            }
        }
    }
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 180)
    }
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate, TaskCellDelegate {
    
    func onEditAction(task: TaskModel) {
        self.openForEdit(with: task)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentLesson?.tasks.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskCell
        if let tast = currentLesson?.tasks[indexPath.row] {
            cell.configure(with: tast)
            cell.delegate = self
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let cell = tableView.cellForRow(at: indexPath) as? TaskCell {
            cell.whiteView.animateTap {
                guard
                    let task = self.currentLesson?.tasks[indexPath.row] else {
                    return
                }
                self.toggleTask(for: task)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard
            let task = currentLesson?.tasks[indexPath.row] else {
            return nil
        }
        
        let deleteAction = UIContextualAction(style: .normal, title: nil) { [weak self]_ , _, handler in
            handler(true)
            self?.delete(for: task)
        }
        
        deleteAction.image = #imageLiteral(resourceName: "delete-icon").scale(to: CGSize(width: 30, height: 30))
        deleteAction.backgroundColor = #colorLiteral(red: 0.9568627451, green: 0.9725490196, blue: 0.9882352941, alpha: 1)
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
}

extension MainViewController {
    
    private func setData() {
        guard
            let results = RealmObjects.objects(type: Task.self) else {
            self.progressView.setProgress(0, animated: true)
            self.tasksForTodayLabel.text = "Нет поручений"
            return
        }
        let tasks: [TaskModel] = results.map {
            TaskModel(id: $0.id, name: $0.name, deadline: $0.deadline, notificationTime: $0.notificationTime, isRemind: $0.isRemind, isFinished: $0.isFinished)
        }
        
        guard
            !tasks.isEmpty else {
            self.progressView.setProgress(0, animated: true)
            self.tasksForTodayLabel.text = "Нет поручений"
            return
        }
        let tasksWithFlag = tasks.filter {
            return $0.isFinished == true
        }
        
        let allTasksCount = tasks.count
        let doneCount = tasksWithFlag.count
        
        let progress: Float = Float(doneCount) / Float(allTasksCount)
        self.progressView.setProgress(progress, animated: true)
        self.tasksForTodayLabel.text = "Всего: \(allTasksCount) / Выполнено: \(doneCount)"
    }
    
    private func recalculateNotifications() {
        notificationCenter.getPendingNotificationRequests { notificationRequests in
            var identifiers: [String] = []
            for request in notificationRequests {
                if request.identifier.hasPrefix(self.identifier) {
                    identifiers.append(request.identifier)
                }
            }
            self.notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.scheduleNotifications()
        }
    }
    
    private func scheduleNotifications() {
        let pendingData = getPendingDates()
        guard !pendingData.isEmpty else {
            return
        }
        
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { result, _ in
            if result == true {
                self.notificationCenter.getNotificationSettings { settings in
                    if settings.authorizationStatus == .authorized {
                        pendingData.forEach { data in
                            let content = UNMutableNotificationContent()
                            content.title = "Время выполнить задачу"
                            content.body = "Нужно выполнить \(data.name)"
                            
                            content.badge = 1
                            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "push.caf"))
                            
                            let dateComponents = Calendar.current.dateComponents([.day, .month, .year, .hour, .minute], from: data.date)
                            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                            let request = UNNotificationRequest(identifier: self.identifier + UUID().uuidString, content: content, trigger: trigger)
                            self.notificationCenter.add(request, withCompletionHandler: nil)
                        }
                    }
                }
            }
        }
    }
    
    private func getPendingDates() -> [(name: String, date: Date)] {
        var pendingData: [(name: String, date: Date)] = []
        guard
            let results = RealmObjects.objects(type: Task.self) else {
            return []
        }
        let tasks: [TaskModel] = results.map {
            TaskModel(id: $0.id, name: $0.name, deadline: $0.deadline, notificationTime: $0.notificationTime, isRemind: $0.isRemind, isFinished: $0.isFinished)
        }
        let tasksWithFlag = tasks.filter {
            return $0.isRemind == true
        }
        
        tasksWithFlag.forEach { task in
            let date = task.deadline
            let time = TimeRange(stringLiteral: task.notificationTime).from
            let calendar = Calendar.current
            var dateComponents = calendar.dateComponents([.day, .month, .year, .hour, .minute], from: date)
            dateComponents.hour = time.hour
            dateComponents.minute = time.minute
            let pendingDate = calendar.date(from: dateComponents) ?? Date()
            pendingData.append((name: task.name, date: pendingDate))
        }

        return pendingData
    }
}
