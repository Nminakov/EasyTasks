//
//  UIButton+Extensions.swift
//  Homework Tasks
//
//  Created by Nikita on 25.10.2020.
//

import UIKit

extension UIView {
    func animateTap(callback: @escaping () -> Void) {
        UIView.animate(withDuration: TimeInterval(0.1)) {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        } completion: { (_) in
            UIView.animate(withDuration: TimeInterval(0.1)) {
                self.transform = CGAffineTransform.identity
            } completion: { (_) in
                callback()
            }
        }
    }
}
