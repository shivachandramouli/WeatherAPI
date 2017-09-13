
import UIKit

//Connection type for the classification of Type of request
public enum ConnectionType {
    
    case get
    case post
    case put
    case delete
    case image
}

/*
    This class is responsible for making a service connection, it initiates a NSURLSession service request based on request
 
    This class can download GET Request, POST request, and Image Request
    In the case of Image requests, the app downloads an image and sends a UIImage back
 */

open class URLSessionManager: NSObject {
    
    
    class func request(_ connectionType: ConnectionType, url: String , data: Data, onSuccess: @escaping (AnyObject) -> Void, onError: @escaping(_ error: Error) -> Void) {
        
        //Handles GET Request
        switch connectionType {
        case ConnectionType.get:
            
            let urlString = url as NSString
            
            //Encode the data
            let encodedUrl = urlString.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
            //Create the NSURLRequest
            let request = NSMutableURLRequest(url: URL(string: encodedUrl!)!)
            request.httpMethod = "GET"
            HTTPsendRequest(request, success: onSuccess, onError: onError)
            
        case ConnectionType.post:
            
            let urlString = url as NSString
            //Encode the data
            let encodedUrl = urlString.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
            
            //Create the NSURLRequest
            let request = NSMutableURLRequest(url: URL(string: encodedUrl!)!)
            
            request.httpMethod = "POST"
            
            //Set HTTP Content Header fields
            request.addValue("application/json",forHTTPHeaderField: "Content-Type")
            request.addValue("application/json",forHTTPHeaderField: "Accept")
            request.httpBody = data
            HTTPsendRequest(request, success: onSuccess, onError: onError)
            
        case ConnectionType.put:
            
            //This method is not completed yet, there is no need for a PUT type for this project
            //This needs to be expanded if there is a need for a put type
            break
            
        case ConnectionType.delete:
            let request = NSMutableURLRequest(url: URL(string: url)! as URL)
            request.httpMethod = "DELETE"
            HTTPsendRequest(request, success: onSuccess, onError: onError)
        case ConnectionType.image:
            
            let urlString = url as NSString
            let encodedUrl = urlString.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
            let request = NSMutableURLRequest(url: URL(string: encodedUrl!)!)
            request.httpMethod = "GET"
            HTTPImageDownloadRequest(request, success: onSuccess, onError: onError)
        }
    }
    
    
    //This function creates a URLSession and spans off a request to the incoming URL
    class func HTTPsendRequest(_ request: NSMutableURLRequest,
                               success: @escaping (AnyObject) -> Void, onError: @escaping (_ error: Error) -> Void) {
        let task = URLSession.shared
            .dataTask(with: request as URLRequest) {
                (data, response, error) -> Void in
                if (error != nil) {
                    onError(error!)
                } else {
                    
                    let jsonString = NSString(data: data!,
                                              encoding: String.Encoding.utf8.rawValue)! as String
                    let jsonData = jsonString.parseJSONString
                    success(jsonData!)
                }
        }
        
        task.resume()
    }
    
    //This function creates a URLSession and spans off a request to the incoming URL, the success callback is a UIImage
    class func HTTPImageDownloadRequest(_ request: NSMutableURLRequest,
                               success: @escaping (UIImage) -> Void, onError: @escaping (_ error: Error) -> Void) {
        let task = URLSession.shared
            .dataTask(with: request as URLRequest) {
                (data, response, error) -> Void in
                if (error != nil) {
                    onError(error!)
                } else {
                    let image = UIImage(data:data!,scale:1.0)
                    if let tempImage = image {
                        success(tempImage)
                    }
                }
        }
        
        task.resume()
    }
}

extension String {
    
    var parseJSONString: AnyObject? {
        
        let data = self.data(using: String.Encoding.utf8, allowLossyConversion: false)
        
        if let jsonData = data {
            // Will return an object or nil if JSON decoding fails
            let jsonResults = try! JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions(rawValue: 0))
            return jsonResults as AnyObject?
        } else {
            return nil
        }
    }
}
