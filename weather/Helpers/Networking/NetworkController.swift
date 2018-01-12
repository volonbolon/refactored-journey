//
//  NetworkController.swift
//  WeatherApp
//
//  Created by Ariel Rodriguez on 11/01/2018.
//  Copyright © 2018 Nyisztor, Karoly. All rights reserved.
//

import Foundation

public protocol NetworkController {
    typealias WeatherCompletionHandler = (Either<NetworkControllerError, WeatherData>) -> Void
    func fetchCurrentWeatherData(input: Input, completionHandler: @escaping WeatherCompletionHandler)
}

public struct WeatherData {
    var temperature: Float
    var condition: String
    var unit: TemperatureUnit
}

public enum TemperatureUnit: String {
    case scientific
    case metric
    case imperial

    init?(code: String) {
        switch code.lowercased() {
        case "c":
            self = .metric
        case "f":
            self = .imperial
        case "s":
            self = .scientific
        default:
            return nil
        }
    }
}

extension TemperatureUnit: CustomStringConvertible {
    public var description: String {
        var description: String
        switch self {
        case .scientific:
            description = "K"
        case .metric:
            description = "C"
        case .imperial:
            description = "F"
        }
        return description
    }
}

public enum NetworkControllerError: Error {
    case invalidURL(String)
    case invalidPayload(URL)
    case forwarded(Error)
}

public struct Input {
    let location: String
    let unit: TemperatureUnit
}
