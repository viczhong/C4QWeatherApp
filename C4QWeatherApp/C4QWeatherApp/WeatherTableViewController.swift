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
    
    let userDefaults = UserDefaults.standard
    let reuseIdentifier = "weatherReuseID"
    let segueIdentifier = "settingsSegue"
    let dateFormatter = DateFormatter()
    var validZip = Bool()
    
    // Possible defaults
    var zipCode = "11101"
    var forecast = [Weather]()
    var tempToggle = true
    var loadedDate: String?
    
    // MARK: Functions and Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshControl?.addTarget(self, action: #selector(WeatherTableViewController.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        loadDefaults()
        getTheWeather(for: zipCode)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.title = "Forecast for \(zipCode)"
    }
    
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        getTheWeather(for: zipCode)
        refreshControl.endRefreshing()
    }
    
    func loadDefaults() {
        if let defaultZip = userDefaults.string(forKey: "Location") {
            zipCode = defaultZip
        }
        
        if let previousWeather = userDefaults.object(forKey: "forecast") as? Data {
            forecast = NSKeyedUnarchiver.unarchiveObject(with: previousWeather) as! [Weather]
        }
        
        if let previousDate = userDefaults.object(forKey: "lastUpdated") as? String {
            loadedDate = previousDate
        }
        
        if let tempConversion = userDefaults.object(forKey: "tempToggle") as? Bool {
            tempToggle = tempConversion
            checkTempToggleForButtonIcon()
        }
    }
    
    func getTheWeather(for zipCode: String) {
        APIRequestManager.manager.getData(endPoint: "http://api.aerisapi.com/forecasts/\(zipCode)?client_id=0tb9dn2PHqjXxZHmGw998&client_secret=GSgql9ruHQOcuMJAREik3PuiXZYoVQXR1OUI6La9", callback: { (data: Data?, error: Error?) in
            if error == nil {
                let currentTime = Date()
                self.dateFormatter.dateFormat = "MMM d, h:mm a"
                let formattedDate = self.dateFormatter.string(from: currentTime)
                self.loadedDate = formattedDate
                self.userDefaults.set(formattedDate, forKey: "lastUpdated")
            }
            
            if let validData = data, let validWeather = Weather.getWeather(from: validData) {
                self.forecast = validWeather.0!
                self.validZip = validWeather.1!
                
                DispatchQueue.main.async {
                    if !self.validZip {
                        presentErrorMessage(zipCode, view: self)
                    }
                    
                    let encodedData = NSKeyedArchiver.archivedData(withRootObject: self.forecast)
                    self.userDefaults.set(encodedData, forKey: "forecast")
                    self.userDefaults.synchronize()
                    self.tableView.reloadData()
                }
            }
        })
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
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let date = self.loadedDate {
            return "Last updated: \(date)"
        }
        
        return  "Last updated: Never"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forecast.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! WeatherTableViewCell
        let forecastAtRow = forecast[indexPath.row]
        cell.weatherIcon.image = UIImage(named: forecastAtRow.icon)
        cell.dateLabel.text = "\(dateStringToReadableString(forecastAtRow.date))"
        cell.weatherLabel.text = forecastAtRow.weather
        cell.tempLabel.text = "High: \(tempToggle ? "\(forecastAtRow.maxTempF)℉" : "\(forecastAtRow.maxTempC)℃"), Low: \(tempToggle ? "\(forecastAtRow.minTempF)℉" : "\(forecastAtRow.minTempC)℃")"
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
            userDefaults.set(zip, forKey: "Location")
            getTheWeather(for: zip)
        }
        
        if temp != tempToggle {
            tempToggle = temp
            self.userDefaults.set(temp, forKey: "tempToggle")
            checkTempToggleForButtonIcon()
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
}
