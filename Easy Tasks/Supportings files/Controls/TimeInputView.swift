//
//  TimeInputView.swift
//  Homework Tasks
//
//  Created by Nikita on 11/8/20.
//

import UIKit
import SnapKit

class TimeInputView: UIView {
    var closeHandler: () -> Void = {}
    var rangeHandler: (String) -> Void = { _ in }
    
    private var selectedColorView: UIView!
    
    private var datePickerFrom: UIDatePicker!
    private var datePickerTo: UIDatePicker!
    
    private var fromTime: Time!
    private var toTime: Time!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        backgroundColor = .clear
        
        let containerView = UIView(frame: .zero)
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 20
        addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(220)
        }

        let button = UIButton(frame: .zero)
        addSubview(button)
        
        button.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(60)
            make.trailing.equalToSuperview().offset(-60)
            make.height.equalTo(40)
        }
        button.backgroundColor = "9f299d".hexColor
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Сохранить", for: .normal)
        button.layer.cornerRadius = 20
        
        let closeButton = UIButton(frame: .zero)
        containerView.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.height.width.equalTo(24)
            make.top.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }
        closeButton.setImage(UIImage(named: "close"), for: .normal)
        closeButton.tintColor = "9f299d".hexColor
        closeButton.addTarget(self, action: #selector(onClose(_:)), for: .touchUpInside)
        
        let titleLabel = UILabel(frame: .zero)
        containerView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(closeButton.snp.centerY)
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
        }
        titleLabel.font = .systemFont(ofSize: 18, weight: .medium)
        titleLabel.textColor = #colorLiteral(red: 0.2043525577, green: 0.1782038212, blue: 0.3159829974, alpha: 1) // "342D51".hexColor
        titleLabel.text = "Установите длительность"
        
        let clearLineView = UIView(frame: .zero)
        containerView.addSubview(clearLineView)
        clearLineView.backgroundColor = .clear
        clearLineView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.bottom.equalToSuperview()
            make.width.equalTo(1)
            make.centerX.equalToSuperview()
        }
        
        datePickerFrom = UIDatePicker(frame: .zero)
        containerView.addSubview(datePickerFrom)
        datePickerFrom.snp.makeConstraints { make in
            make.top.equalTo(clearLineView.snp.top).offset(10)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalTo(clearLineView.snp.leading)
            make.bottom.equalToSuperview().offset(-10)
        }
        if #available(iOS 13.4, *) {
            datePickerFrom.preferredDatePickerStyle = .wheels
        }
        datePickerFrom.datePickerMode = .time
        datePickerFrom.locale = Locale(identifier: "ru_RU")
        
        datePickerTo = UIDatePicker(frame: .zero)
        containerView.addSubview(datePickerTo)
        datePickerTo.snp.makeConstraints { make in
            make.top.equalTo(clearLineView.snp.top).offset(10)
            make.leading.equalTo(clearLineView.snp.trailing)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-10)
        }
        if #available(iOS 13.4, *) {
            datePickerTo.preferredDatePickerStyle = .wheels
        }
        datePickerTo.datePickerMode = .time
        datePickerTo.locale = Locale(identifier: "ru_RU")
        
        let fromLabel = UILabel(frame: .zero)
        containerView.addSubview(fromLabel)
        
        fromLabel.snp.makeConstraints { make in
            make.bottom.equalTo(datePickerFrom.snp.top)
            make.centerX.equalTo(datePickerFrom.snp.centerX)
        }
        fromLabel.text = "Начало"
        fromLabel.font = .systemFont(ofSize: 12)
        fromLabel.textColor = #colorLiteral(red: 0.2043525577, green: 0.1782038212, blue: 0.3159829974, alpha: 1) // "342D51".hexColor
        
        let toLabel = UILabel(frame: .zero)
        containerView.addSubview(toLabel)
        
        toLabel.snp.makeConstraints { make in
            make.bottom.equalTo(datePickerTo.snp.top)
            make.centerX.equalTo(datePickerTo.snp.centerX)
        }
        toLabel.text = "Конец"
        toLabel.font = .systemFont(ofSize: 12)
        toLabel.textColor = #colorLiteral(red: 0.2043525577, green: 0.1782038212, blue: 0.3159829974, alpha: 1) // "342D51".hexColor
        
        datePickerFrom.addTarget(self, action: #selector(fromValueChanged(_:)), for: .valueChanged)
        datePickerTo.addTarget(self, action: #selector(toValueChanged(_:)), for: .valueChanged)
        button.addTarget(self, action: #selector(onSave(_:)), for: .touchUpInside)
    }
    
    func configure(for string: String) {
        if string == "" {
            return
        }
        let range = TimeRange(stringLiteral: string)
        self.fromTime = range.from
        self.toTime = range.to
        
        var fromComponents = DateComponents()
        fromComponents.hour = fromTime.hour
        fromComponents.minute = fromTime.minute
        
        var toComponents = DateComponents()
        toComponents.hour = toTime.hour
        toComponents.minute = toTime.minute
        
        if let fromDate = Calendar.current.date(from: fromComponents), let toDate = Calendar.current.date(from: toComponents) {
            DispatchQueue.main.async { [weak self] in
                self?.datePickerFrom.setDate(fromDate, animated: true)
                self?.datePickerTo.setDate(toDate, animated: true)
            }
        }
    }
    
    @objc private func fromValueChanged(_ sender: UIDatePicker) {
        let time = prepate(for: sender.date)
        self.fromTime = time
    }
    
    @objc private func toValueChanged(_ sender: UIDatePicker) {
        let time = prepate(for: sender.date)
        self.toTime = time
    }
    
    @objc private func onClose(_ sender: UIButton) {
        closeHandler()
    }
    
    @objc private func onSave(_ sender: UIButton) {
        let range = TimeRange(from: fromTime, to: toTime)
        sender.animateTap {
            self.rangeHandler(range.formattedRange)
        }
    }
 
    func prepate(for date: Date) -> Time {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date)
        if let hour = components.hour, let minute = components.minute {
            let time = Time(hour: hour, minute: minute)
            return time
        }
        
        return Time(hour: 0, minute: 0)
    }
    
}
