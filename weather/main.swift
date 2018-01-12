//
//  main.swift
//  weather
//
//  Created by Ariel Rodriguez on 08/01/2018.
//  Copyright © 2018 Ariel Rodriguez. All rights reserved.
//

import Foundation

func parseInput() -> Input? {
    var location = ""
    var unit = "C"
    let arguments = CommandLine.arguments
    if arguments.count <= 1 {
        print("HELP: You need to provide location")
    } else {
        enum ParsingTokensFor {
            case unkown
            case location
            case unit
        }

        var parsing: ParsingTokensFor = .unkown
        for index in 1..<arguments.count {
            let arg = arguments[index]
            let characterSet = CharacterSet(charactersIn: "-")
            if arg.rangeOfCharacter(from: characterSet) != nil {
                switch arg {
                case "-l":
                    parsing = .location
                case "-u":
                    parsing = .unit
                default:
                    parsing = .unkown
                }
            } else {
                switch parsing {
                case .location:
                    location += "\(arg) "
                case .unit:
                    unit = arg
                default:
                    break
                }
            }
        }
    }

    if let temperatureUnit = TemperatureUnit(code: unit) {
        let input = Input(location: location, unit: temperatureUnit)
        return input
    }

    return nil
}

func retrieveTemp(input: Input) {
    let semaphore = DispatchSemaphore(value: 0)
    let controller = OpenWeatherMapNetworkController()
    controller.fetchCurrentWeatherData(input: input) { (result: Either<NetworkControllerError, WeatherData>) in
//        DispatchQueue.main.async {
            switch result {
            case .left:
                printHelp()
            case .right(let data):
                let city = input.location
                print("Weather in \(city): \(data.condition), \(data.temperature)\(data.unit)")
                semaphore.signal()
            }
//        }
    }
    _ = semaphore.wait(timeout: DispatchTime.distantFuture)
}

func printHelp() {
    let warningString = """
HELP: You need to provide the location, and, if you provide the unit,
it should be [S]cientific, [C]elcius or [F]ahrenheit
"""
    let warning = NSLocalizedString(warningString, comment: "Warning String")
    print(warning)
}

if let input = parseInput() {
    retrieveTemp(input: input)
} else {
    printHelp()
}
