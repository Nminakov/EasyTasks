//
//  LessonInputView.swift
//  Homework Tasks
//
//  Created by Nikita on 25.10.2020.
//

import UIKit
import SnapKit

class ColorCollectionViewCell: UICollectionViewCell {
    private var color: UIColor! {
        didSet {
            backgroundColor = color
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 20
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with color: UIColor) {
        self.color = color
    }
}

class LessonInputView: UIView {
    var resultHandler: (_ color: UIColor, _ name: String) -> Void = { _, _ in }
    var closeHandler: () -> Void = { }
    
    private var name: String?
    private var color: UIColor?
    
    private var selectedColorView: UIView!
    
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
            make.height.equalTo(140)
        }

        let textField = UITextField(frame: .zero)
        containerView.addSubview(textField)
        
        textField.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(40)
        }
        textField.placeholder = "Введите задачу"
        textField.addTarget(self, action: #selector(onEdit(_:)), for: .editingChanged)
        textField.tintColor = "9f299d".hexColor
        
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = .horizontal
        collectionViewLayout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        containerView.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
        }
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: "colorCell")
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .clear
        
        let button = UIButton(frame: .zero)
        addSubview(button)
        
        button.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(40)
            make.leading.equalToSuperview().offset(60)
            make.trailing.equalToSuperview().offset(-60)
            make.height.equalTo(40)
        }
        button.backgroundColor = "9f299d".hexColor
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Создать", for: .normal)
        button.layer.cornerRadius = 20
        button.addTarget(self, action: #selector(onCreate(_:)), for: .touchUpInside)
        
        selectedColorView = UIView(frame: .zero)
        addSubview(selectedColorView)
        selectedColorView.backgroundColor = .white
        
        selectedColorView.snp.makeConstraints { make in
            make.centerY.equalTo(button.snp.centerY)
            make.leading.equalToSuperview().offset(20)
            make.height.width.equalTo(20)
        }
        selectedColorView.layer.cornerRadius = 10
        
        let closeButton = UIButton(frame: .zero)
        containerView.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.height.width.equalTo(24)
            make.top.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }
        closeButton.setImage(UIImage(named: "close"), for: .normal)
        closeButton.addTarget(self, action: #selector(onClose(_:)), for: .touchUpInside)
        closeButton.tintColor = "9f299d".hexColor
    }
    
    @objc private func onClose(_ sender: UIButton) {
        sender.animateTap {
            self.closeHandler()
        }
    }
    
    @objc private func onCreate(_ sender: UIButton) {
        sender.animateTap {
            guard let name = self.name, name != "", let color = self.color else {
                return
            }
            self.resultHandler(color, name)
        }
    }
    
    @objc private func onEdit(_ sender: UITextField) {
        self.name = sender.text
    }
    
}

extension LessonInputView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "colorCell", for: indexPath) as! ColorCollectionViewCell
        cell.backgroundColor = colors[indexPath.item]
        return cell
    }
}

extension LessonInputView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let color = colors[indexPath.item]
        self.color = color
        selectedColorView.backgroundColor = color
    }
}

extension LessonInputView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 40, height: 40)
    }
}
