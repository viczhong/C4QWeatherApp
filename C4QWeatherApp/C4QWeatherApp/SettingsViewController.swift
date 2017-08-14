//
//  SettingsViewController.swift
//  C4QWeatherApp
//
//  Created by Victor Zhong on 8/14/17.
//  Copyright © 2017 Victor Zhong. All rights reserved.
//

import UIKit

protocol SettingsDelegate {
    func changeSettings(_ controller: SettingsViewController, _ zip: String, _ temp: Bool)
}

class SettingsViewController: UIViewController {
    // MARK: Properties and Outlets
    @IBOutlet weak var conversionPicker: UISegmentedControl!
    @IBOutlet weak var applyButton: UIButton!
    @IBOutlet weak var zipCodeTextField: UITextField!
    
    var delegate: SettingsDelegate!
    var zipCode: String!
    var tempToggle: Bool!
    
    // MARK: Functions and Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        displayTemp()
        zipCodeTextField.delegate = self
        zipCodeTextField.text = zipCode
    }
    
    @IBAction func applyButtonTapped(_ sender: Any) {
        delegate.changeSettings(self, zipCode, tempToggle)
    }
    
    @IBAction func conversionPickerTapped(_ sender: UISegmentedControl) {

        if sender.selectedSegmentIndex == 0 {
            tempToggle = true
        } else {
            tempToggle = false
        }
    }
        
    func displayTemp() {
        if tempToggle {
            conversionPicker.selectedSegmentIndex = 0
        } else {
            conversionPicker.selectedSegmentIndex = 1
        }
    }
}

extension SettingsViewController: UITextFieldDelegate {
    // MARK: - UITextField Stuff
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let search = textField.text {
            zipCode = search
            if search.characters.count != 5 {
                presentErrorMessage(search, view: self)
            } else {
                applyButtonTapped(self)
            }
        }
        textField.resignFirstResponder()
        return true
    }
}
