

import UIKit

public class WeatherImageAPI: NSObject {

    //Pass the imageURL to this server API. OnSuccess callback, there is a weather Image data being returned
    //from service, OnError callback, the error from web service is being returned
    public func getWeatherImage(url: String, onSuccess: @escaping (_ weatherImage: WeatherImage) -> Void, onError: @escaping (_ error: Error) -> Void) {
        
        URLSessionManager.request(.image, url: url, data: Data(), onSuccess: { (serviceResponse) in
            
            let weatherImage = WeatherImage()
            weatherImage.weatherImage = serviceResponse as? UIImage
            onSuccess(weatherImage)
            
        }, onError: { (error) in
            
            onError(error)
        })
    }
}
