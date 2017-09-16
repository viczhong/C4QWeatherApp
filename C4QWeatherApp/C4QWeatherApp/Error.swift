//
//  Error.swift
//  C4QWeatherApp
//
//  Created by Victor Zhong on 8/14/17.
//  Copyright © 2017 Victor Zhong. All rights reserved.
//

import Foundation
import UIKit

enum ErrorMessageType {
    case zipCode, string
}

func presentErrorMessage(_ error: String, type errorType: ErrorMessageType, view viewController: UIViewController) {
    
    var errorMessage = String()
    
    switch errorType {
    case .zipCode: errorMessage = "\(error) is not a valid zip code!"
    case .string: errorMessage = error
    }
    
    let alertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
    
    alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
    viewController.present(alertController, animated: true, completion: nil)
}
