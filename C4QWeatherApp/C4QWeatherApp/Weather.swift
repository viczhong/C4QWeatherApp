//
//  Weather.swift
//  C4QWeatherApp
//
//  Created by Victor Zhong on 8/7/17.
//  Copyright © 2017 Victor Zhong. All rights reserved.
//

import Foundation

enum WeatherModelParseError: Error {
    case results, parsing
}

class Weather {
    let date: String
    let minTempF: Int
    let maxTempF: Int
    let minTempC: Int
    let maxTempC: Int
    let icon: String
    let weather: String
    
    init(date: String,
         minTempF: Int,
         maxTempF: Int,
         minTempC: Int,
         maxTempC: Int,
         icon: String,
         weather: String)
    {
        self.date = date
        self.maxTempF = maxTempF
        self.minTempF = minTempF
        self.maxTempC = maxTempC
        self.minTempC = minTempC
        self.icon = icon
        self.weather = weather
    }
    
    convenience init?(from dict: [String : Any]) throws {
        guard let dateTimeISO = dict["dateTimeISO"] as? String,
            let maxTempF = dict["maxTempF"] as? Int,
            let minTempF = dict["minTempF"] as? Int,
            let maxTempC = dict["maxTempC"] as? Int,
            let minTempC = dict["minTempC"] as? Int,
            let icon = dict["icon"] as? String,
            let weather = dict["weather"] as? String else { throw WeatherModelParseError.parsing }
        
        self.init(date: dateTimeISO,
                  minTempF: minTempF,
                  maxTempF: maxTempF,
                  minTempC: minTempC,
                  maxTempC: maxTempC,
                  icon: icon,
                  weather: weather)
    }
    
    static func getWeather(from data: Data) -> ([Weather]?, Bool?)? {
        var weatherToReturn: [Weather]? = []
        var successBool: Bool?
        do {
            let jsonData: Any = try JSONSerialization.jsonObject(with: data, options: [])
            
            guard let json = jsonData as? [String : Any],
                let responses = json["response"] as? [[String : Any]] else {
                    throw WeatherModelParseError.results
            }
            
            if let success = json["success"] as? Bool {
                successBool = success
            }
            
            for response in responses {
                guard let periods = response["periods"] as? [[String : Any]] else {
                    throw WeatherModelParseError.results
                }
                
                for weatherDict in periods {
                    if let weather = try Weather(from: weatherDict) {
                        weatherToReturn?.append(weather)
                    }
                }
            }
        }
            
        catch {
            print("Error encountered with \(error)")
        }
        
        return (weatherToReturn, successBool)
    }
}


//Verify that you are able to obtain a JSON response from the API, and familiarize yourself with the JSON results. You will need the minTempF and maxTempF fields for low and high temperatures, and dateTimeISO field for the forecast date.
/*
 {
 "timestamp": 1502103600,
 "validTime": "2017-08-07T07:00:00-04:00",
 "dateTimeISO": "2017-08-07T07:00:00-04:00",
 "maxTempC": 23,
 "maxTempF": 73,
 "minTempC": 19,
 "minTempF": 66,
 "avgTempC": 21,
 "avgTempF": 70,
 "tempC": null,
 "tempF": null,
 "pop": 100,
 "precipMM": 49.45,
 "precipIN": 1.95,
 "iceaccum": 0,
 "maxHumidity": 93,
 "minHumidity": 38,
 "humidity": 80,
 "uvi": 2,
 "pressureMB": 1018,
 "pressureIN": 30.06,
 "sky": 98,
 "snowCM": 0,
 "snowIN": 0,
 "feelslikeC": 20,
 "feelslikeF": 68,
 "minFeelslikeC": 19,
 "minFeelslikeF": 66,
 "maxFeelslikeC": 22,
 "maxFeelslikeF": 72,
 "avgFeelslikeC": 20,
 "avgFeelslikeF": 68,
 "dewpointC": 15,
 "dewpointF": 59,
 "maxDewpointC": 18,
 "maxDewpointF": 64,
 "minDewpointC": 15,
 "minDewpointF": 59,
 "avgDewpointC": 17,
 "avgDewpointF": 63,
 "windDirDEG": 310,
 "windDir": "NW",
 "windDirMaxDEG": 140,
 "windDirMax": "SE",
 "windDirMinDEG": 80,
 "windDirMin": "E",
 "windGustKTS": 17,
 "windGustKPH": 31,
 "windGustMPH": 19,
 "windSpeedKTS": 6,
 "windSpeedKPH": 12,
 "windSpeedMPH": 7,
 "windSpeedMaxKTS": 11,
 "windSpeedMaxKPH": 21,
 "windSpeedMaxMPH": 13,
 "windSpeedMinKTS": 3,
 "windSpeedMinKPH": 5,
 "windSpeedMinMPH": 3,
 "windDir80mDEG": 208,
 "windDir80m": "SSW",
 "windDirMax80mDEG": 140,
 "windDirMax80m": "SE",
 "windDirMin80mDEG": 80,
 "windDirMin80m": "E",
 "windGust80mKTS": 16,
 "windGust80mKPH": 30,
 "windGust80mMPH": 19,
 "windSpeed80mKTS": 11,
 "windSpeed80mKPH": 21,
 "windSpeed80mMPH": 13,
 "windSpeedMax80mKTS": 16,
 "windSpeedMax80mKPH": 30,
 "windSpeedMax80mMPH": 19,
 "windSpeedMin80mKTS": 3,
 "windSpeedMin80mKPH": 6,
 "windSpeedMin80mMPH": 4,
 "weather": "Cloudy with Light Rain",
 "weatherCoded": [
 {
 "timestamp": 1502132400,
 "wx": "D:L:R",
 "dateTimeISO": "2017-08-07T15:00:00-04:00"
 }
 ],
 "weatherPrimary": "Light Rain",
 "weatherPrimaryCoded": "D:L:R",
 "cloudsCoded": "OV",
 "icon": "rain.png",
 "isDay": true,
 "sunrise": 1502099947,
 "sunriseISO": "2017-08-07T05:59:07-04:00",
 "sunset": 1502150627,
 "sunsetISO": "2017-08-07T20:03:47-04:00"
 }
 */
