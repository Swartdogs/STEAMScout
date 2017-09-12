//
//  Match.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 6/12/17.
//  Copyright © 2017 dhanwada. All rights reserved.
//

import Foundation

protocol Match : CsvDataProvider, MatchCoding {
    
    // Team Info
    
    var teamNumber:Int         { get set }
    var matchNumber:Int        { get set }
    var alliance:AllianceType  { get set }
    var isCompleted:Int        { get set }
    
    // Final Info
    
    var finalScore:Int         { get set }
    var finalRankingPoints:Int { get set }
    var finalResult:ResultType { get set }
    var finalPenaltyScore:Int  { get set }
    var finalFouls:Int         { get set }
    var finalTechFouls:Int     { get set }
    var finalYellowCards:Int   { get set }
    var finalRedCards:Int      { get set }
    var finalRobot:RobotState  { get set }
    var finalComments:String   { get set }
    
    // Match Manipulation Data
    var selectedForDataTransfer:Bool { get set }
    
    // Calculated Variables
    var messageDictionary:Dictionary<String, AnyObject> { get }
    
    init(queueData:MatchQueueData)
    
    // Required Functions
    func updateForType(_ type:UpdateType, withMatch match:Match)
    func aggregateMatchData()
}
