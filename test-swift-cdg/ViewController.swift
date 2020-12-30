//
//  ViewController.swift
//  test-swift-cdg
//
//  Created by Evgen on 22.12.2020.
//

import UIKit
import Photos

class ViewController: UIViewController {
    
    var gallery = [UIImage]()
    
    var nextRightIndex = 0
    var nextLeftIndex = -1
    var currentPicture: UIImageView?
    var leftPreview: UIImageView?
    var rightPreview: UIImageView?
    let originalSize: CGFloat = 300
    let intervalFromSide: CGFloat = 300

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getPhotosAndStart()
    }
    
    func getPhotosAndStart() {
        let manager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .highQualityFormat
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let results: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        if results.count > 0 {
            for i in 0..<results.count {
                let asset = results.object(at: i)
                let size = CGSize(width: 300, height: 300)
                manager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: requestOptions) { (image, _) in
                    if let image = image {
                        self.gallery.append(image)
                    }
                    
                    if i == results.count - 1 {
                        self.startShow()
                    }
                }
            }
        }
    }
    
    func startShow() {
        if let imageView = createRightPreview(imageIndex: nextRightIndex) {
            currentPicture = imageView
            transformToMainImage(imageView: currentPicture!)
            showView(currentPicture)
            addSwipeHandles(currentPicture!)
            nextRightIndex += 1
        }
        
        if let imageView = createRightPreview(imageIndex: nextRightIndex) {
            rightPreview = imageView
            showView(rightPreview)
            nextRightIndex += 1
        }
    }
    
    func addSwipeHandles(_ imageView: UIImageView) {
        imageView.isUserInteractionEnabled = true
        addLeftSwipeHandle(imageView)
        addRightSwipeHandle(imageView)
    }
    
    func addLeftSwipeHandle(_ imageView: UIImageView) {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(self.handleLeftSwipe(_:)))
        swipe.direction = .left
        imageView.addGestureRecognizer(swipe)
    }
    
    func addRightSwipeHandle(_ imageView: UIImageView) {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(self.handleRightSwipe(_:)))
        swipe.direction = .right
        imageView.addGestureRecognizer(swipe)
    }
    
    @objc func handleLeftSwipe(_ sender: UISwipeGestureRecognizer) {
        if rightPreview == nil {
            return
        }
        
        if leftPreview != nil {
            leftPreview?.removeFromSuperview()
            nextLeftIndex += 1
        }
        
        leftPreview = currentPicture
        leftPreview?.isUserInteractionEnabled = false
        currentPicture = rightPreview
        
        UIView.animate(withDuration: 0.4){
            self.transformToLeftPreview(imageView: self.leftPreview!)
            self.transformToMainImage(imageView: self.currentPicture!)
        }
        
        addSwipeHandles(currentPicture!)
        rightPreview = createRightPreview(imageIndex: nextRightIndex)
        showView(rightPreview)
        
        if nextRightIndex < gallery.count {
            nextRightIndex += 1
        }
    }
    
    @objc func handleRightSwipe(_ sender: UISwipeGestureRecognizer) {
        if leftPreview == nil {
            return
        }
        
        if rightPreview != nil {
            rightPreview?.removeFromSuperview()
            nextRightIndex -= 1
        }
        
        rightPreview = currentPicture
        rightPreview?.isUserInteractionEnabled = false
        currentPicture = leftPreview
        
        UIView.animate(withDuration: 0.4){
            self.transformToRightPreview(imageView: self.rightPreview!)
            self.transformToMainImage(imageView: self.currentPicture!)
        }
        
        addSwipeHandles(currentPicture!)
        leftPreview = createLeftPreview(imageIndex: nextLeftIndex)
        showView(leftPreview)
        
        if nextLeftIndex >= 0 {
            nextLeftIndex -= 1
        }
    }
    
    func showView(_ view: UIImageView?) {
        guard view != nil else {
            return
        }
        
        self.view.addSubview(view!)
    }
    
    func createRightPreview(imageIndex: Int) -> UIImageView? {
        guard imageIndexValidate(imageIndex: imageIndex) else {
            return nil
        }
        
        let imageView = createPreview(imageIndex: imageIndex)
        transformToRightPreview(imageView: imageView)
        return imageView
    }
    
    func createLeftPreview(imageIndex: Int) -> UIImageView? {
        guard imageIndexValidate(imageIndex: imageIndex) else {
            return nil
        }
        
        let imageView = createPreview(imageIndex: imageIndex)
        transformToLeftPreview(imageView: imageView)
        return imageView
        
    }
    
    func transformToRightPreview(imageView: UIImageView) {
        imageView.center.x = self.view.center.x + intervalFromSide
        let layer = imageView.layer
        layer.anchorPoint = CGPoint(x: 1.0, y: 0.5)
        var rotationAndPerspectiveTransform = CATransform3DIdentity
        rotationAndPerspectiveTransform.m14 = 1 / -500.0
        rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, 70.0 * .pi / 180.0, 0.0, 1.0, 0.0)
        layer.transform = rotationAndPerspectiveTransform
    }
    
    func transformToLeftPreview(imageView: UIImageView) {
        imageView.center.x = self.view.center.x - intervalFromSide
        let layer = imageView.layer
        layer.anchorPoint = CGPoint(x: 0.0, y: 0.5)
        var rotationAndPerspectiveTransform = CATransform3DIdentity
        rotationAndPerspectiveTransform.m14 = 1 / 500.0
        rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, 70.0 * .pi / 180.0, 0.0, 1.0, 0.0)
        layer.transform = rotationAndPerspectiveTransform
    }
    
    func transformToMainImage(imageView: UIImageView) {
        imageView.center.x = self.view.center.x
        let layer = imageView.layer
        layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        var rotationAndPerspectiveTransform = CATransform3DIdentity
        rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, 0.0, 0.0, 0.0, 0.0)
        layer.transform = rotationAndPerspectiveTransform
    }
    
    func imageIndexValidate(imageIndex: Int) -> Bool {
        return imageIndex < gallery.count && imageIndex >= 0
        
    }
    
    func createPreview(imageIndex: Int) -> UIImageView {
        let imageView = UIImageView(image: gallery[imageIndex])
        imageView.frame = CGRect(x: 0, y: self.view.center.y - (originalSize / 2), width: originalSize, height: originalSize)
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.darkGray.cgColor
        return imageView
    }
}

extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
