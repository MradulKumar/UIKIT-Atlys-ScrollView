//
//  CustomCarouselView.swift
//  UIKIT-Atlys-ScrollView
//
//  Created by Mradul Kumar on 23/09/24.
//

import UIKit

class CustomCarouselView: UIView {
    private let pagingControlHeight: CGFloat = 30
    private let imageZoomSpace: CGFloat = 40
    
    private var containerScrollView = UIScrollView()
    private var pageControlView = UIPageControl()
    private var viewModel: CustomCarouselViewModel
    
    init(frame: CGRect, viewModel: CustomCarouselViewModel) {
        //initializing properties
        self.viewModel = viewModel
        
        //super.init call
        super.init(frame: frame)
        
        //setup
        setupPageControl()
        setupContainerScrollView()
        setupContent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Computed Properties
private extension CustomCarouselView {
    
    var viewItemSize: CGFloat {
        return self.bounds.height - imageZoomSpace - pagingControlHeight
    }
}

// MARK: - Private Methods
private extension CustomCarouselView {
    
    func setupContainerScrollView() {
        containerScrollView.delegate = self
        containerScrollView.showsHorizontalScrollIndicator = false
        containerScrollView.isPagingEnabled = false
        containerScrollView.decelerationRate = .fast
        containerScrollView.translatesAutoresizingMaskIntoConstraints = false
        containerScrollView.contentInset = UIEdgeInsets(top: 0, left: viewItemSize / 2, bottom: 0, right: viewItemSize / 2)
        addSubview(containerScrollView)
        
        NSLayoutConstraint.activate([
            containerScrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerScrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerScrollView.topAnchor.constraint(equalTo: topAnchor),
            containerScrollView.bottomAnchor.constraint(equalTo: pageControlView.topAnchor)
        ])
    }
    
    func setupPageControl() {
        pageControlView.numberOfPages = viewModel.images.count
        pageControlView.currentPage = 0
        pageControlView.pageIndicatorTintColor = .lightGray.withAlphaComponent(0.8)
        pageControlView.currentPageIndicatorTintColor = .black
        pageControlView.hidesForSinglePage = true
        pageControlView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(pageControlView)
        
        NSLayoutConstraint.activate([
            pageControlView.leadingAnchor.constraint(equalTo: leadingAnchor),
            pageControlView.trailingAnchor.constraint(equalTo: trailingAnchor),
            pageControlView.bottomAnchor.constraint(equalTo: bottomAnchor),
            pageControlView.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    func setInitialContentOffset() {
        let initialImageIndex = viewModel.images.count / 2
        let initialOffset = CGFloat(initialImageIndex) * viewItemSize - (frame.width - viewItemSize) / 2
        containerScrollView.contentOffset = CGPoint(x: initialOffset, y: 0)
        viewModel.currentlyVisiblePageIndex = initialImageIndex
        pageControlView.currentPage = viewModel.currentlyVisiblePageIndex
        updateImageScaling()
    }
    
    func createImageView(with imageName: String) -> UIImageView {
        let imageView = UIImageView()
        imageView.image = UIImage(named: imageName)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        return imageView
    }
    
    func setupContent() {
        var lastView: UIImageView?
        
        viewModel.images.forEach { imageName in
            let imageView = createImageView(with: imageName)
            containerScrollView.addSubview(imageView)
            
            imageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: viewItemSize),
                imageView.heightAnchor.constraint(equalToConstant: viewItemSize),
                imageView.centerYAnchor.constraint(equalTo: containerScrollView.centerYAnchor)
            ])
            
            if let last = lastView {
                imageView.leadingAnchor.constraint(equalTo: last.trailingAnchor).isActive = true
            } else {
                imageView.leadingAnchor.constraint(equalTo: containerScrollView.leadingAnchor).isActive = true
            }
            
            lastView = imageView
        }
        
        if let last = lastView {
            last.trailingAnchor.constraint(equalTo: containerScrollView.trailingAnchor).isActive = true
        }
        
        containerScrollView.contentSize = CGSize(width: CGFloat(viewModel.images.count) * viewItemSize, height: containerScrollView.bounds.height)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.setInitialContentOffset()
        }
    }
    
}

// MARK: - UIScrollViewDelegate
extension CustomCarouselView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateImageScaling()
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let targetX = targetContentOffset.pointee.x
        
        if velocity.x > 0 {
            viewModel.currentlyVisiblePageIndex = min(viewModel.currentlyVisiblePageIndex + 1, viewModel.images.count - 1)
        } else if velocity.x < 0 {
            viewModel.currentlyVisiblePageIndex = max(viewModel.currentlyVisiblePageIndex - 1, 0)
        } else {
            viewModel.currentlyVisiblePageIndex = Int(round(targetX / viewItemSize))
        }
        
        let newOffsetX = CGFloat(viewModel.currentlyVisiblePageIndex) * viewItemSize - (frame.width - viewItemSize) / 2
        targetContentOffset.pointee = CGPoint(x: newOffsetX, y: targetContentOffset.pointee.y)
        pageControlView.currentPage = viewModel.currentlyVisiblePageIndex
    }
}

// MARK: - Scrolling and Animations
extension CustomCarouselView {
    
    func updateImageScaling() {
        let centerX = containerScrollView.center.x + containerScrollView.contentOffset.x
        containerScrollView.subviews.forEach { imageView in
            let distanceFromCenter = centerX - imageView.center.x
            let thresholdDistance = viewItemSize / 2
            
            if abs(distanceFromCenter) <= thresholdDistance {
                let normalizedDistance = abs(distanceFromCenter) / thresholdDistance
                let scale = 1 + (0.2 * (1 - normalizedDistance))
                imageView.transform = CGAffineTransform(scaleX: scale, y: scale)
            } else {
                imageView.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
            
            if abs(distanceFromCenter) < viewItemSize / 2 {
                containerScrollView.bringSubviewToFront(imageView)
            }
        }
    }
}

