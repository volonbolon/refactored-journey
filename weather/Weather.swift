//
//  Weather.swift
//  weather
//
//  Created by Ariel Rodriguez on 08/01/2018.
//  Copyright © 2018 Ariel Rodriguez. All rights reserved.
//

import Foundation

enum WeatherError: Error {
    case urlError
    case illFormattedLocation
}

class Weather {
    func getTemperature(location: String, completionHandler: @escaping (String) -> Void) throws {
        let na = NSLocalizedString("NA", comment: "NA")
        guard location.count > 3 else {
            completionHandler(na)
            throw WeatherError.illFormattedLocation
        }
        guard var URL = URL(string: "https://query.yahooapis.com/v1/public/yql") else {
            completionHandler(na)
            throw WeatherError.urlError
        }

        let URLParams = [
            "q": """
            select item.condition from weather.forecast where woeid in
            (select woeid from geo.places(1) where text=\"\(location.lowercased())\")
            and u='c'
            """,
            "format": "json",
            "env": "store://datatables.org/alltableswithkeys"
        ]
        URL = URL.appendingQueryParameters(URLParams)
        var request = URLRequest(url: URL)
        request.httpMethod = "GET"

        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data: Data?, _: URLResponse?, error: Error?) in
            if error != nil {
                completionHandler(na)
            } else {
                guard let data = data else {
                    completionHandler(na)
                    return
                }
                do {
                    let options = JSONSerialization.ReadingOptions.mutableLeaves
                    if let json = try JSONSerialization.jsonObject(with: data, options: options) as? [String: Any] {
                        if let query = json["query"] as? [String: Any],
                            let results = query["results"] as? [String: Any],
                            let channel = results["channel"] as? [String: Any],
                            let item = channel["item"] as? [String: Any],
                            let condition = item["condition"] as? [String: Any],
                            let temp = condition["temp"] as? String {
                            completionHandler(temp)
                        }
                    }
                } catch {
                    completionHandler(na)
                }
            }
        }
        task.resume()
    }
}
//
protocol URLQueryParameterStringConvertible {
    var queryParameters: String {get}
}

extension Dictionary: URLQueryParameterStringConvertible {
    /**
     This computed property returns a query parameters string from the given NSDictionary. For
     example, if the input is @{@"day":@"Tuesday", @"month":@"January"}, the output
     string will be @"day=Tuesday&month=January".
     @return The computed parameters string.
     */
    var queryParameters: String {
        var parts: [String] = []
        for (key, value) in self {
            let part = String(format: "%@=%@",
                              String(describing: key).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
                              String(describing: value).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
            parts.append(part as String)
        }
        return parts.joined(separator: "&")
    }

}

extension URL {
    /**
     Creates a new URL by adding the given query parameters.
     @param parametersDictionary The query parameter dictionary to add.
     @return A new URL.
     */
    func appendingQueryParameters(_ parametersDictionary: [String: String]) -> URL {
        let URLString: String = String(format: "%@?%@", self.absoluteString, parametersDictionary.queryParameters)
        return URL(string: URLString)!
    }
}
