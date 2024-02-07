//
//  Extends.swift
//  Gardener
//
//  Created by 유현진 on 2023/10/25.
//

import Foundation
import UIKit
import Kingfisher
import FirebaseStorage

extension UIImageView{
    func setImageView(url: String){
        let cache = ImageCache.default
        cache.retrieveImage(forKey: url, options: nil) { result in
            switch result{
            case .success(let value):
                if let image = value.image{
                    self.image = image
                }else{
                    let storageReference = Storage.storage().reference(forURL: url)
                    storageReference.downloadURL { url, error in
                        if error != nil{
                            print("downloadUrl Error")
                            return
                        }
                        if let url = url{
                            self.kf.setImage(with: url)
                        }
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension UIImage{
    func setImage(url: String, completion: @escaping (UIImage?) -> Void){
        DispatchQueue.global().async {
            let url = URL(string: url)
            do{
                let data = try Data(contentsOf: url!)
                DispatchQueue.main.async {
                    completion(UIImage(data: data))
                }
            }catch let error{
                print(error.localizedDescription)
                return
            }
        }
    }
    
    func rotate(by: CGFloat) -> UIImage{
        let rotatedView = UIView(frame: .init(x: 0, y: 0, width: size.width, height: size.height))
        let affineTransform = CGAffineTransform(rotationAngle: by * CGFloat.pi / 180)
        rotatedView.transform = affineTransform
        
        let rotatedSize = rotatedView.frame.size
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap = UIGraphicsGetCurrentContext()!
        bitmap.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
        bitmap.rotate(by: by * CGFloat.pi / 180)
        bitmap.scaleBy(x: 1.0, y: -1.0)
        bitmap.draw(cgImage!, in: .init(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}

extension UITextView{
    func alignTextVerticallyInContainer() {
        var topCorrect = (self.bounds.size.height - self.contentSize.height * self.zoomScale) / 2
        topCorrect += self.textContainerInset.top
        topCorrect = topCorrect < 0.0 ? 0.0 : topCorrect;
        
        self.contentInset.top = topCorrect
    }
}

extension UITextView{
    func resolveHashTags() {
        var hashtagArr: [String]?
        
        let nsText: NSString = self.text as NSString
        let attrString = NSMutableAttributedString(string: nsText as String)
        let hashtagDetector = try? NSRegularExpression(pattern: "#(\\w+)", options: NSRegularExpression.Options.caseInsensitive)
        let results = hashtagDetector?.matches(in: self.text,
                                               options: NSRegularExpression.MatchingOptions.withoutAnchoringBounds,
                                               range: NSMakeRange(0, self.text.utf16.count))
        
        hashtagArr = results?.map{ (self.text as NSString).substring(with: $0.range(at: 1)) }
        
        if hashtagArr?.count != 0 {
            var i = 0
            for var word in hashtagArr! {
                word = "#" + word
                if word.hasPrefix("#") {
                    let matchRange:NSRange = nsText.range(of: word as String, options: [.caseInsensitive, .backwards])
                    let linkAttributes: [NSAttributedString.Key: Any] = [
                        .foregroundColor: UIColor.black,
                        .font: UIFont.systemFont(ofSize: 15, weight: .medium),
                        .backgroundColor: UIColor.systemGray6
                    ]
                    attrString.setAttributes(linkAttributes, range: matchRange)
//                    attrString.addAttribute(NSAttributedString.Key.link, value: "\(i)", range: matchRange)
                    i += 1
                }
            }
        }
        let nonHashtagAttributes: [NSAttributedString.Key: Any] = [
              .foregroundColor: UIColor.black,
              .font: UIFont.systemFont(ofSize: 15, weight: .medium),
          ]
          let nonHashtagRange = NSRange(location: 0, length: nsText.length)
          attrString.addAttributes(nonHashtagAttributes, range: nonHashtagRange)
          
        self.attributedText = attrString
    }
}
