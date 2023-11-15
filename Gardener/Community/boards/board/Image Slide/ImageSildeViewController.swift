//
//  ImageSildeViewController.swift
//  Gardener
//
//  Created by 유현진 on 2023/11/16.
//

import UIKit
import SnapKit

class ImageSildeViewController: UIViewController {
    
    var imageUrls: [String]?
    var cur: Int? 
    
    private lazy var ImageScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        return scrollView
    }()
    
    private lazy var baseView: UIView = {
        return UIView()
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = .gray
        return pageControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initImages()
        initPageControl()
    }
    
    private func initUI(){
        self.view.backgroundColor = .white
        let backBarButton = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        backBarButton.tintColor = .white
        self.navigationItem.backBarButtonItem = backBarButton
        
        
        self.view.addSubview(ImageScrollView)
        self.ImageScrollView.addSubview(baseView)
        self.view.addSubview(pageControl)
        
//        ImageScrollView.delegate = self
        ImageScrollView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-30)
            make.left.right.equalToSuperview()
        }
        
        baseView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        pageControl.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
    }
    
    func initImages(){
        guard let imageUrls = imageUrls else {
            return
        }
        
        for i in 0..<imageUrls.count{
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            let xPosition = ImageScrollView.frame.width * CGFloat(i)
            imageView.frame = CGRect(x: xPosition, y: 0, width: ImageScrollView.bounds.width, height: ImageScrollView.bounds.height)
            imageView.setImage(url: imageUrls[i])
            ImageScrollView.addSubview(imageView)
            ImageScrollView.contentSize.width = imageView.frame.width * CGFloat(i + 1)
        }
        ImageScrollView.delegate = self
        // imageScrollView.contentsize가 계속 바뀌기 때문에 scrollViewDidScroll 호출되는 것을 방지
    }
    
    func initPageControl(){
        guard let imageUrls = imageUrls, let cur = cur else { return }
        pageControl.numberOfPages = imageUrls.count
        pageControl.currentPage = cur
    }
    
    func setPageControl(current: Int){
        pageControl.currentPage = current
    }
}
extension ImageSildeViewController: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let value = ImageScrollView.contentOffset.x / ImageScrollView.frame.size.width
        setPageControl(current: Int(round(value)))
    }
}
