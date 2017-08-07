//
//  WeatherTableViewController.swift
//  C4QWeatherApp
//
//  Created by Victor Zhong on 8/7/17.
//  Copyright © 2017 Victor Zhong. All rights reserved.
//

import UIKit

class WeatherTableViewController: UITableViewController, UITextFieldDelegate {
    // MARK: Properties and Outlets
    @IBOutlet weak var zipCodeField: UITextField!
    var zipCode = "11101"
    var validZip = Bool()
    var weatherAPIURL = "http://api.aerisapi.com/forecasts/11101?client_id=0tb9dn2PHqjXxZHmGw998&client_secret=GSgql9ruHQOcuMJAREik3PuiXZYoVQXR1OUI6La9"
    let reuseIdentifier = "weatherReuseID"
    var forecast = [Weather]()
    var tempToggle = true
    @IBOutlet weak var tempToggleButton: UIBarButtonItem!
    @IBAction func tempToggleButtonPressed(_ sender: UIBarButtonItem) {
        toggleTempButtonPressed()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        zipCodeField.delegate = self
        getTheWeather(for: zipCode)
    }
    
    // MARK: Functions and Methods
    func getTheWeather(for zipCode: String) {
        APIRequestManager.manager.getData(endPoint: "http://api.aerisapi.com/forecasts/\(zipCode)?client_id=0tb9dn2PHqjXxZHmGw998&client_secret=GSgql9ruHQOcuMJAREik3PuiXZYoVQXR1OUI6La9") { (data: Data?) in
            if let validData = data, let validWeather = Weather.getWeather(from: validData) {
                self.forecast = validWeather.0!
                self.validZip = validWeather.1!
                
                DispatchQueue.main.async {
                    if !self.validZip {
                        let alertController = UIAlertController(title: "Error", message: "\(zipCode) is not a valid zip code!", preferredStyle: .alert)
                        
                        alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                    }
                    
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func dateStringToReadableString(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        //"2017-08-07T07:00:00-04:00"
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let date = dateFormatter.date(from: dateString)
        
        let newFormatter = DateFormatter()
        newFormatter.dateFormat = "MMM d, yyyy"
        
        if let date = date {
            return newFormatter.string(from: date)
        } else {
            return "Date Error"
        }
    }
    
    func toggleTempButtonPressed() {
        tempToggle = !tempToggle
        
        if tempToggle {
            tempToggleButton.title = "🔄℉"
        } else {
            tempToggleButton.title = "🔄℃"
        }
        
        self.tableView.reloadData()
    }
    
    // MARK: - UITextField Stuff
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let search = textField.text {
            zipCode = search
            getTheWeather(for: search)
        }
        
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forecast.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        
        let forecastAtRow = forecast[indexPath.row]
        cell.imageView?.image = UIImage(named: forecastAtRow.icon)
        cell.detailTextLabel?.text = "\(dateStringToReadableString(forecastAtRow.date))"
        cell.textLabel?.text = "High: \(tempToggle ? "\(forecastAtRow.maxTempF)℉" : "\(forecastAtRow.maxTempC)℃"), Low: \(tempToggle ? "\(forecastAtRow.minTempF)℉" : "\(forecastAtRow.minTempC)℃")"
        
        return cell
    }
}
