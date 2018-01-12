//
//  Either.swift
//  WeatherApp
//
//  Created by Ariel Rodriguez on 12/01/2018.
//  Copyright © 2018 Nyisztor, Karoly. All rights reserved.
//

import Foundation

public enum Either<T1, T2> {
    case left(T1)
    case right(T2)
}
