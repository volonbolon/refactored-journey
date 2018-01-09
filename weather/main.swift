//
//  main.swift
//  weather
//
//  Created by Ariel Rodriguez on 08/01/2018.
//  Copyright © 2018 Ariel Rodriguez. All rights reserved.
//

import Foundation

print("Hello, World!")

for arg in CommandLine.arguments {
    print(arg)
}

let weather = Weather()

let semaphore = DispatchSemaphore(value: 0)

do {
    try weather.getTemperature(location: "buenos Aires, argentina") { (temp: String) in
        print("Temp: \(temp)°C")
        semaphore.signal()
    }
} catch {
    print(error)
}

_ = semaphore.wait(timeout: DispatchTime.distantFuture)
