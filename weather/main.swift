//
//  main.swift
//  weather
//
//  Created by Ariel Rodriguez on 08/01/2018.
//  Copyright © 2018 Ariel Rodriguez. All rights reserved.
//

import Foundation

struct Input {
    let location: String
    let unit: String
}

func parseInput() -> Input {
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

    let input = Input(location: location, unit: unit)
    return input
}

func retrieveTemp(input: Input) {
    let weather = Weather()

    let semaphore = DispatchSemaphore(value: 0)

    do {
        try weather.getTemperature(input: input) { (temp: String) in
            print("Temp: \(temp)°\(input.unit)")
            semaphore.signal()
        }
    } catch {
        print(error)
    }

    _ = semaphore.wait(timeout: DispatchTime.distantFuture)
}

let input = parseInput()
retrieveTemp(input: input)
