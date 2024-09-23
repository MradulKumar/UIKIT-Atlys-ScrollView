//
//  ViewController.swift
//  UIKIT-Atlys-ScrollView
//
//  Created by Mradul Kumar on 23/09/24.
//

import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCarouselView()
    }
}

// MARK: - Private Methods
private extension ViewController {
    
    func setupCarouselView() {
        let frame = CGRectMake(0, 200, view.bounds.width, 250)
        let carouselView = CustomCarouselView(frame: frame, viewModel: CustomCarouselViewModel())
        view.addSubview(carouselView)
    }
}
