//
//  CreateTaskViewController.swift
//  Homework Tasks
//
//  Created by Nikita on 10.10.2020.
//

import UIKit

enum Modes {
    case create, edit
}

class CreateTaskViewController: UIViewController {
    
    var closeHandler: () -> Void = { }
    
    var lessonIdentifier: String?
    var task: TaskModel?
    var mode: Modes = .create
    
    private var date: Date! {
        didSet {
            self.setDateButton()
        }
    }
    private var notificationTime = ""
    private var isRemind = false
    private var gestureRecognizer: UITapGestureRecognizer {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(onGesture(_:)))
        return gesture
    }
    @IBOutlet weak var closeButton: UIButton! {
        didSet {
            closeButton.layer.cornerRadius = 12
            
            closeButton.layer.shadowColor = UIColor.gray.cgColor
            closeButton.layer.shadowOffset = .zero
            closeButton.layer.shadowRadius = 8
            closeButton.layer.shadowOpacity = 0.3
            
            closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        }
    }
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var roundWhiteView: UIView!
    
    @IBOutlet weak var textField: UITextField! {
        didSet {
            let color = #colorLiteral(red: 0.662745098, green: 0.7333333333, blue: 0.7882352941, alpha: 1)
            textField.attributedPlaceholder = NSAttributedString(string: "Введите адрес", attributes: [NSAttributedString.Key.foregroundColor: color])
        }
    }
    
    @IBOutlet weak var calendarButton: UIButton!
    @IBOutlet weak var timeButton: UIButton!
    @IBOutlet weak var remindMeLabel: UILabel! {
        didSet {
            remindMeLabel.text = "Напомнить"
        }
    }
    @IBOutlet weak var remindMeSwitch: UISwitch!
    @IBOutlet weak var taskButton: UIButton!
    
    lazy private var maskLayer: CAShapeLayer = {
        let cornerRadius: CGFloat = 20
        let layer = CAShapeLayer()
        let bounds = CGRect(x: 0, y: 0, width: view.frame.width, height: roundWhiteView.frame.height)
        let bezierPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
        layer.path = bezierPath
        return layer
    }()
    
    @objc private func onGesture(_ gesture: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    @objc private func closeButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func calendarButtonTapped(_ sender: UIButton) {
        let helper = DateInputViewHelper(with: view)
        helper.configure(with: self.date)
        helper.dateHandler = { date in
            self.date = date
        }
        helper.show()
    }
    
    @IBAction func timeButtonTapped(_ sender: UIButton) {
        let helper = TimeInputViewHelper(with: view)
        helper.rangeHandler = { string in
            self.notificationTime = string
            self.timeButton.setTitle(string, for: .normal)
        }
        helper.configure(with: self.notificationTime)
        helper.show()
    }
    
    @IBAction func onSwitch(_ sender: UISwitch) {
        self.isRemind = sender.isOn
        self.remindMeSwitch.isOn = self.isRemind
        
    }
    
    @IBAction func onCreate(_ sender: UIButton) {
        sender.animateTap {
            guard
                let text = self.textField.text,
                text != "", self.notificationTime != "" else {
                return
            }
            
            let task = TaskModel(name: text, deadline: self.date, notificationTime: self.notificationTime, isRemind: self.isRemind)
            
            switch self.mode {
            case .create:
                self.create(task: task)
            case .edit:
                self.update(task: task)
            }
            
            self.closeHandler()
            self.dismiss(animated: true, completion: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.date = Date()
        self.remindMeSwitch.isOn = isRemind
        roundWhiteView.layer.mask = maskLayer
        prepareDefaultTime()
        setData()
        
        view.addGestureRecognizer(gestureRecognizer)
        
        textField.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
}

extension CreateTaskViewController: UIScrollViewDelegate {
    
}

extension CreateTaskViewController {
    
    private func prepareDefaultTime() {
        let date = Date()
        let calendar = Calendar.current
        
        var dateComponents = calendar.dateComponents([.hour, .minute], from: date)
        if let fromHour = dateComponents.hour, let fromMinute = dateComponents.minute {
            let fromTime = Time(hour: fromHour, minute: fromMinute)
            let nextDate = calendar.date(byAdding: .minute, value: 30, to: date) ?? date
            dateComponents = calendar.dateComponents([.hour, .minute], from: nextDate)
            if let toHour = dateComponents.hour, let toMinute = dateComponents.minute {
                let toTime = Time(hour: toHour, minute: toMinute)
                let range = TimeRange(from: fromTime, to: toTime)
                self.notificationTime = range.formattedRange
            }
        }
    }
    
    private func setDateButton() {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "ru_RU")
        let string = formatter.string(from: self.date)
        self.calendarButton.setTitle(string, for: .normal)
    }
    
    private func setData() {
        switch mode {
        case .create:
            titleLabel.text = "Новая"
            descriptionLabel.text = "Задача"
            taskButton.setTitle("Создать Задачу", for: .normal)
        case .edit:
            titleLabel.text = "Изменить"
            descriptionLabel.text = "Задачу"
            taskButton.setTitle("Обновить Задачу", for: .normal)
            
            guard
                let task = self.task else {
                return
            }
            
            self.textField.text = task.name
            self.date = task.deadline
            self.notificationTime = task.notificationTime
            self.isRemind = task.isRemind
            
            setDateButton()
            let timeRange = TimeRange(stringLiteral: self.notificationTime)
            timeButton.setTitle(timeRange.formattedRange, for: .normal)
        }
    }

    private func create(task: TaskModel) {
        guard
            let identifier = lessonIdentifier,
            let lesson = RealmObjects.objects(type: Lesson.self)?.filter("id = '\(identifier)'").first else {
            return
        }

        let realmTask = Task()
        realmTask.id = task.id
        realmTask.name = task.name
        realmTask.deadline = task.deadline
        realmTask.notificationTime = task.notificationTime
        realmTask.isRemind = task.isRemind
        realmTask.isFinished = task.isFinished
        realmTask.addWithPrimaryKey()
        
        lesson.update {
            lesson.tasks.append(realmTask)
        }
    }
    
    private func update(task: TaskModel) {
        guard
            let taskIdentifier = self.task?.id,
            let object = RealmObjects.objects(type: Task.self)?.filter("id = '\(taskIdentifier)'").first else {
            return
        }
        object.update {
            object.name = task.name
            object.deadline = task.deadline
            object.notificationTime = task.notificationTime
            object.isRemind = task.isRemind
            object.isFinished = task.isFinished
        }
        
    }
    
}
