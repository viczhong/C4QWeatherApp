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
    let weatherAPIURL = "http://api.aerisapi.com/forecasts/11101?client_id=0tb9dn2PHqjXxZHmGw998&client_secret=GSgql9ruHQOcuMJAREik3PuiXZYoVQXR1OUI6La9"
    let reuseIdentifier = "weatherReuseID"
    var forecast = [Weather]()
    var tempToggle = true
    @IBOutlet weak var tempToggleButton: UIBarButtonItem!
    
    @IBAction func tempToggleButtonPressed(_ sender: UIBarButtonItem) {
        toggleTempButtonPressed()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getTheWeather()
    }
    
    // MARK: Functions and Methods
    func getTheWeather() {
        APIRequestManager.manager.getData(endPoint: weatherAPIURL) { (data: Data?) in
            if let validData = data, let validWeather = Weather.getWeather(from: validData) {
                self.forecast = validWeather
                DispatchQueue.main.async {
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}
