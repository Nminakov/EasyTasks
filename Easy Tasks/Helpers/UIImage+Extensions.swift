//
//  UIImage+Extensions.swift
//  Homework Tasks
//
//  Created by Nikita on 11/7/20.
//

import UIKit

extension UIImage {
    func scale(to newSize: CGSize) -> UIImage? {
        let horizontalRatio = newSize.width / size.width
        let verticalRatio = newSize.height / size.height
        let ratio = max(horizontalRatio, verticalRatio)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage?.withRenderingMode(self.renderingMode)
    }
}
