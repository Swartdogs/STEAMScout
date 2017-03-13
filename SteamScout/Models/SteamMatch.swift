//
//  SteamMatch.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 3/12/17.
//  Copyright © 2017 dhanwada. All rights reserved.
//

import Foundation
import SwiftyJSON

class SteamMatch : MatchImpl {
    
    // Auto Info
    var autoStartPos:Int         = 0        // Replace with Enum!
    var autoBaselineCrossed:Bool = false
    var autoGearPlacement:Int    = 0        // Replace with Enum!
    var autoHopperTriggered:Bool = false
    var autoHighFuelScored:Float = 0.0
    var autoLowFuelScored:Float  = 0.0
    
    // Tele Info
    var teleGearsScored:Int      = 0
    var teleHighFuelScored:Float = 0.0
    var teleLowFuelScored:Float  = 0.0
    
    // Final Info
    var finalConfiguration:FinalConfigType = .none
    
    required init(queueData:MatchQueueData) {
        super.init(queueData: queueData)
    }
    
    required init() {
        super.init()
    }
    
    required init(withPList pList: [String : AnyObject]) {
        // Call Super to init team and final info
        super.init(withPList: pList)
        
        let auto  = pList["auto"]  as! [String:AnyObject]
        let tele  = pList["tele"]  as! [String:AnyObject]
        let final = pList["final"] as! [String:AnyObject]
        
        // Auto Info
        autoStartPos        = auto["startPos"]   as! Int
        autoBaselineCrossed = auto["blCross"]    as! Bool
        autoGearPlacement   = auto["gearPlace"]  as! Int
        autoHopperTriggered = auto["hTrigger"]   as! Bool
        autoHighFuelScored  = auto["hFuelScore"] as! Float
        autoLowFuelScored   = auto["lFuelScore"] as! Float
        
        // Tele Info
        teleGearsScored     = tele["gearScore"]  as! Int
        teleHighFuelScored  = tele["hFuelScore"] as! Float
        teleLowFuelScored   = tele["lFuelScore"] as! Float
        
        // Final Info (Specific to this class)
        finalConfiguration = FinalConfigType(rawValue: final["config"] as! Int)!
    }
    
    override var messageDictionary: Dictionary<String, AnyObject> {
        // Call Super to get team and final info
        var data = super.messageDictionary
        var auto = [String:AnyObject]()
        var tele = [String:AnyObject]()
        var final = data["final"] as! [String:AnyObject]
        
        // Auto Info
        auto["startPos"]   = autoStartPos        as AnyObject?
        auto["blCross"]    = autoBaselineCrossed as AnyObject?
        auto["gearPlace"]  = autoGearPlacement   as AnyObject?
        auto["hTrigger"]   = autoHopperTriggered as AnyObject?
        auto["hFuelScore"] = autoHighFuelScored  as AnyObject?
        auto["lFuelScore"] = autoLowFuelScored   as AnyObject?
        
        // Tele Info
        tele["gearScore"]  = teleGearsScored     as AnyObject?
        tele["hFuelScore"] = teleHighFuelScored  as AnyObject?
        tele["lFuelScore"] = teleLowFuelScored   as AnyObject?
        
        // Final Info (Specific to this class)
        final["config"]    = finalConfiguration.rawValue as AnyObject?
        
        data["auto"]  = auto  as AnyObject?
        data["tele"]  = tele  as AnyObject?
        data["final"] = final as AnyObject?
        
        return data
    }
    
    override var encodingHelper: MatchEncodingHelper {
        fatalError("This function needs to be implemented")
    }
    
    override class var csvHeader: String {
        var matchHeader = ""
        
        // Team Info
        matchHeader += "Match Number, Team Number, Alliance, "
        
        // Auto Info
        matchHeader += "Auto Start Position, Auto Baseline Crossed, Auto Gear Placement, Auto Hopper Triggered, Auto High Fuel Scored, Auto Low Fuel Scored"
        
        // Tele Info
        matchHeader += "Tele Gears Scored, Tele High Fuel Scored, Tele Low Fuel Scored"
        
        // Final Info
        matchHeader += "Final Score, Final Ranking Points, Penalty Points Received, Final Result, Fouls, Tech Fouls, Yellow Cards, Red Cards, Robot, Config, Comments \r\n"
        
        return matchHeader
    }
    
    override var csvMatch: String {
        var matchData = ""
        let match = JSON(messageDictionary)
        
        // Team Info
        matchData += "\(match["team", "matchNumber"].intValue),"
        matchData += "\(match["team", "teamNumber"].intValue),"
        matchData += "\(match["team", "alliance"].stringValue),"
        
        // Auto Info
        matchData += "\(match["auto", "startPos"].intValue),"
        matchData += "\(match["auto", "blCross"].boolValue),"
        matchData += "\(match["auto", "gearPlace"].intValue),"
        matchData += "\(match["auto", "hTrigger"].boolValue),"
        matchData += "\(match["auto", "hFuelScore"].floatValue),"
        matchData += "\(match["auto", "lFuelScore"].floatValue),"
        
        // Tele Info
        matchData += "\(match["tele", "gearScore"].intValue),"
        matchData += "\(match["tele", "hFuelScore"].floatValue),"
        matchData += "\(match["tele", "lFuelScore"].floatValue),"
        
        // Final Info
        let finalKeys = ["score", "rPoints", "pScore", "result", "fouls", "tFouls", "yCards", "rCards", "robot", "config"]
        for i in 0..<finalKeys.count {
            matchData += "\(match["final", finalKeys[i]].intValue),"
        }
        matchData += "\(match["final", "comments"].stringValue)"
        
        return matchData
    }
    
    override func updateForType(_ type: UpdateType, withMatch match: Match) {
        let m = match as! SteamMatch
        switch type {
        case .teamInfo:
            teamNumber = m.teamNumber
            matchNumber = m.matchNumber
            alliance = m.alliance
            isCompleted = m.isCompleted
            finalResult = m.finalResult
        case .finalStats:
            finalScore         = m.finalScore
            finalRankingPoints = m.finalRankingPoints
            finalResult        = m.finalResult
            finalPenaltyScore  = m.finalPenaltyScore
            finalConfiguration = m.finalConfiguration
            finalComments      = m.finalComments
        default:
            break
        }
    }
}

class SteamMatchEncodingHelper : MatchEncodingHelper {
    override init(match:Match) {
        super.init(match: match)
    }
    
    required init?(coder aDecoder: NSCoder) {
        // user decoderrequired init?(coder aDecoder: NSCoder) {
        
        // use decoder to get dictionary
        guard let pList = aDecoder.decodeObject(forKey: "pListData") as? [String:AnyObject] else {
            super.init()
            match = nil
            return
        }
        
        super.init()
        
        // convert dictionary to match here
        match = SteamMatch(withPList: pList)
    }
    
    override func propertyListRepresentation() throws -> [String : AnyObject] {
        var auto = [String:AnyObject]()
        var tele = [String:AnyObject]()
        
        // call super to get the tele and final information
        guard var data = try? super.propertyListRepresentation() else {
            throw MatchEncodingError.NoMatchData
        }
        // Get the final dictionary to add the config
        var final = data["final"] as! [String:AnyObject]
        
        guard let m = match as? SteamMatch else {
            throw MatchEncodingError.NoMatchData
        }
        
        // Auto Info
        auto["startPos"]   = m.autoStartPos        as AnyObject?
        auto["blCross"]    = m.autoBaselineCrossed as AnyObject?
        auto["gearPlace"]  = m.autoGearPlacement   as AnyObject?
        auto["hTrigger"]   = m.autoHopperTriggered as AnyObject?
        auto["hFuelScore"] = m.autoHighFuelScored  as AnyObject?
        auto["lFuelScore"] = m.autoLowFuelScored   as AnyObject?
        
        // Tele Info
        tele["gearScore"]  = m.teleGearsScored     as AnyObject?
        tele["hFuelScore"] = m.teleHighFuelScored  as AnyObject?
        tele["lFuelScore"] = m.teleLowFuelScored   as AnyObject?
        
        // Final Info (Specific to this class)
        final["config"]    = m.finalConfiguration.rawValue as AnyObject?
        
        data["auto"]            = auto             as AnyObject?
        data["tele"]            = tele             as AnyObject?
        data["final"]           = final            as AnyObject?
        
        return data
    }
}
