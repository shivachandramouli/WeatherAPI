

import UIKit

public class WeatherAPI: NSObject {

    //Pass the imageURL to this server API. OnSuccess callback, there is a WeatherAPICollection data being returned
    //from service, OnError callback, the error from web service is being returned

    public func getWeatherInfo(url: String, onSuccess: @escaping (_ weatherModel: WeatherAPICollection) -> Void, onError: @escaping (_ error: Error) -> Void) {
        
        URLSessionManager.request(.get, url: url, data: Data(), onSuccess: { (serviceResponse) in
            
            let response = serviceResponse as? NSDictionary
            if let responseData = response {
                let weatherAPICollection = self.parseWeatherData(dictionary: responseData)
                onSuccess(weatherAPICollection)
            }
        }, onError: { (error) in
            
            onError(error)
        })
    }
    
    //This method parses the WeatheAPICollection Data
    func parseWeatherData(dictionary: NSDictionary) -> WeatherAPICollection {
        
        let weatherAPICollection = WeatherAPICollection()
        
        //Parse the dictionary which contains the Key "list"
        let listArray = dictionary.object(forKey: "list") as! NSArray
        
        for i in 0...listArray.count - 1 {
            
            //Extract the elements in WeatherAPIModel
            let weatherAPIModel = WeatherAPIModel()
            
            let dict = listArray.object(at: i) as? NSDictionary
            let mainDict = dict?.object(forKey: "main") as? NSDictionary
            weatherAPIModel.minTemp = mainDict?.object(forKey: "temp_min") as? Double
            weatherAPIModel.maxTemp = mainDict?.object(forKey: "temp_max") as? Double
            let currentTemp = mainDict?.object(forKey: "temp") as? Double
            if let kelvinTemp = currentTemp {
                weatherAPIModel.currentTemp = convertKelvinToFarenheit(kelvin: kelvinTemp)
            }
            
            
            //Parse the weather data that contains the key "weather"
            
            let weatherArray = dict?.object(forKey: "weather") as? NSArray
            
            //Loop the weather array until every data has been accounted for
            for i in 0...(weatherArray?.count)! - 1 {
                
                //Extract the elements in WeatherInfoModel
                let weatherInfoModel = WeatherInfoModel()
                let dict = weatherArray?.object(at: i) as? NSDictionary
                weatherInfoModel.weatherId = dict?.object(forKey: "id") as? Int
                weatherInfoModel.main = dict?.object(forKey: "main") as? String
                weatherInfoModel.weatherDescription = dict?.object(forKey: "description") as? String
                weatherInfoModel.icon = dict?.object(forKey: "icon") as? String
                
                weatherAPICollection.weatherInfoModel.append(weatherInfoModel)
            }
            
            let weatherDateModel = WeatherDateModel()
            weatherDateModel.date = dict?.object(forKey: "dt_txt") as? String
            weatherAPICollection.weatherAPIModel.append(weatherAPIModel)
            weatherAPICollection.weatherDateModel.append(weatherDateModel)
        }
        //return weather API Collection. This can be used by any ViewController that has to invoke weather data
        return weatherAPICollection
    }
    
    //Utility method for converting kelvin to Farenheit
    func convertKelvinToFarenheit(kelvin: Double) -> Double {
        
        let farenheit = (9/5) * (kelvin - 273) + 32
        return farenheit
    }
}
