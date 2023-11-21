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
    
    private var touchPoint = CGPoint(x: 0, y: 0)
    private var panGestureGecognizer: UIPanGestureRecognizer!
    
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
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        initPanGestureRecognizer()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initImages()
        initPageControl()
    }
    
    private func initUI(){
        self.view.backgroundColor = .black
        
        let backBarButton = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        backBarButton.tintColor = .white
        self.navigationItem.backBarButtonItem = backBarButton
        
        
        self.view.addSubview(ImageScrollView)
        self.ImageScrollView.addSubview(baseView)
        self.view.addSubview(pageControl)
        self.view .addSubview(cancelButton)
        
        ImageScrollView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(-30)
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
        
        cancelButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(50)
            make.left.equalToSuperview().offset(10)
            make.width.height.equalTo(45)
        }
        
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
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
        if let cur = cur{
            ImageScrollView.contentOffset.x = ImageScrollView.bounds.width * CGFloat(cur)
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
    
    func initPanGestureRecognizer(){
        panGestureGecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestPopView))
        panGestureGecognizer.delegate = self
        self.ImageScrollView.addGestureRecognizer(panGestureGecognizer)
    }
    
    @objc func panGestPopView(_ sender: UIPanGestureRecognizer){
        let translation = sender.translation(in: ImageScrollView)
        switch sender.state{
        case .began:
            touchPoint = sender.location(in: ImageScrollView)
        case .changed:
            ImageScrollView.frame.origin.y = max(translation.y, 0)
            let alphaValue = 1.0 - min(translation.y / 200.0, 1.0)
            ImageScrollView.alpha = alphaValue
        case .ended:
            let dragDistance = touchPoint.y - translation.y
            if dragDistance < 180{
                dismiss(animated: true)
            }else{
                UIView.animate(withDuration: 0.3){
                    self.ImageScrollView.frame.origin.y = 0
                    self.ImageScrollView.alpha = 1
                }
            }
        default : break
        }
        if translation.y < -50{
            dismiss(animated: true)
        }
    }
    
    @objc func cancel(){
        dismiss(animated: true)
    }
}
extension ImageSildeViewController: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let value = ImageScrollView.contentOffset.x / ImageScrollView.frame.size.width
        setPageControl(current: Int(round(value)))
    }
}
extension ImageSildeViewController: UIGestureRecognizerDelegate{
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = panGesture.velocity(in: ImageScrollView)
            return abs(velocity.x) < abs(velocity.y) // 위 아래로 당길 때만 panGesture 실행
        }
        return true
    }
}
