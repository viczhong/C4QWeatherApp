//
//  WeatherTableViewController.swift
//  C4QWeatherApp
//
//  Created by Victor Zhong on 8/7/17.
//  Copyright © 2017 Victor Zhong. All rights reserved.
//

import UIKit

class WeatherTableViewController: UITableViewController {
    // MARK: Properties and Outlets
    @IBOutlet weak var zipCodeField: UITextField!
    @IBOutlet weak var tempToggleButton: UIBarButtonItem!
    var zipCode = "11101"
    var validZip = Bool()
    var weatherAPIURL = "http://api.aerisapi.com/forecasts/11101?client_id=0tb9dn2PHqjXxZHmGw998&client_secret=GSgql9ruHQOcuMJAREik3PuiXZYoVQXR1OUI6La9"
    let reuseIdentifier = "weatherReuseID"
    let segueIdentifier = "settingsSegue"
    var forecast = [Weather]()
    var tempToggle = true
    
    // MARK: Functions and Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        getTheWeather(for: zipCode)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.title = "Forecast for \(zipCode)"
    }
    
    func getTheWeather(for zipCode: String) {
        APIRequestManager.manager.getData(endPoint: "http://api.aerisapi.com/forecasts/\(zipCode)?client_id=0tb9dn2PHqjXxZHmGw998&client_secret=GSgql9ruHQOcuMJAREik3PuiXZYoVQXR1OUI6La9") { (data: Data?) in
            if let validData = data, let validWeather = Weather.getWeather(from: validData) {
                self.forecast = validWeather.0!
                self.validZip = validWeather.1!
                DispatchQueue.main.async {
                    if !self.validZip {
                        presentErrorMessage(zipCode, view: self)
                    }
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func dateStringToReadableString(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let date = dateFormatter.date(from: dateString)
        let newFormatter = DateFormatter()
        newFormatter.dateFormat = "EEEE, MMMM d, yyyy"
        if let date = date {
            return newFormatter.string(from: date)
        } else {
            return "Date Error"
        }
    }
    
    func checkTempToggleForButtonIcon() {
        if tempToggle {
            tempToggleButton.title = "🔄℉"
        } else {
            tempToggleButton.title = "🔄℃"
        }
        self.tableView.reloadData()
    }
    
    
    // MARK: - Table view data source
    
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueIdentifier {
            let vc = segue.destination as! SettingsViewController
            vc.delegate = self
            vc.zipCode = zipCode
            vc.tempToggle = tempToggle
        }
    }
}

extension WeatherTableViewController: SettingsDelegate {
    func changeSettings(_ controller: SettingsViewController, _ zip: String, _ temp: Bool) {
        if zip != zipCode {
            zipCode = zip
            getTheWeather(for: zip)
        }
        
        if temp != tempToggle {
            tempToggle = temp
            checkTempToggleForButtonIcon()
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
}
