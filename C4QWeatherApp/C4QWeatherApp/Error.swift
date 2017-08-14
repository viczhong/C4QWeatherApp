//
//  Error.swift
//  C4QWeatherApp
//
//  Created by Victor Zhong on 8/14/17.
//  Copyright © 2017 Victor Zhong. All rights reserved.
//

import Foundation
import UIKit

func presentErrorMessage(_ zipCode: String, view viewController: UIViewController) {
    let alertController = UIAlertController(title: "Error", message: "\(zipCode) is not a valid zip code!", preferredStyle: .alert)
    
    alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
    viewController.present(alertController, animated: true, completion: nil)
}
