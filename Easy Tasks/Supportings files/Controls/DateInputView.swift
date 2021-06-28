//
//  DateInputView.swift
//  Homework Tasks
//
//  Created by Nikita on 11/8/20.
//

import UIKit
import SnapKit

class DateInputView: UIView {
    var closeHandler: () -> Void = {}
    var dateHandler: (Date) -> Void = { _ in }
    
    private var selectedColorView: UIView!
    
    private var datePicker: UIDatePicker!
    
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
            make.height.equalTo(200)
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
        }
        titleLabel.font = .systemFont(ofSize: 18, weight: .medium)
        titleLabel.textColor = #colorLiteral(red: 0.2043525577, green: 0.1782038212, blue: 0.3159829974, alpha: 1) // "342D51".hexColor
        titleLabel.text = "Установите дату"
        
        datePicker = UIDatePicker(frame: .zero)
        containerView.addSubview(datePicker)
        datePicker.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-10)
        }
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.minimumDate = Date()
        
        button.addTarget(self, action: #selector(onSave(_:)), for: .touchUpInside)
    }
    
    func configure(with date: Date) {
        self.datePicker.date = date
    }
    
    @objc private func onSave(_ sender: UIButton) {
        sender.animateTap {
            let date = self.datePicker.date
            self.dateHandler(date)
        }
    }
    
    @objc private func onClose(_ sender: UIButton) {
        closeHandler()
    }
}
