//
//  OpenWeatherMapDataMappings.swift
//  WeatherApp
//
//

import Foundation

struct OpenMapWeatherData: Codable {
    var weather: [OpenMapWeatherWeather]
    var main: OpenMapWeatherMain
}

struct OpenMapWeatherWeather: Codable {
    // swiftlint:disable identifier_name
    var id: Int
    var main: String
    var description: String
    var icon: String
}

struct OpenMapWeatherMain: Codable {
    var temp: Float
}
