//
//  CsvDataProvider.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 6/12/17.
//  Copyright © 2017 dhanwada. All rights reserved.
//

import Foundation

protocol CsvDataProvider {
    static var csvHeader:String { get }
    var csvMatch:String { get }
}
