//
//  Match.swift
//  StrongScout
//
//  Created by Srinivas Dhanwada on 2/6/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import UIKit
import SwiftyJSON

class MatchImpl : AnyObject, Match {
    
    // Team Info
    
    var teamNumber:Int         = 0
    var matchNumber:Int        = 0
    var alliance:AllianceType  = .unknown
    var isCompleted:Int        = 0
    
    // Final Info
    
    var finalScore:Int         = 0
    var finalRankingPoints:Int = 0
    var finalResult:ResultType = .none
    var finalPenaltyScore:Int  = 0
    var finalFouls:Int         = 0
    var finalTechFouls:Int     = 0
    var finalYellowCards:Int   = 0
    var finalRedCards:Int      = 0
    var finalRobot:RobotState  = .None
    var finalComments:String   = ""
    
    // Calculated Variables
    class var csvHeader:String {
        var matchHeader = ""
        
        matchHeader += "Match Number, Team Number, Alliance, "
        matchHeader += "Final Score, Final Ranking Points, Penalty Points Received, Final Result, Fouls, Tech Fouls, "
        matchHeader += "Yellow Cards, Red Cards, Robot, Config, Comments \r\n"
        
        return matchHeader
    }
    
    var csvMatch:String {
        var matchData = ""
        matchData += "\(matchNumber), \(teamNumber), \(alliance.toString)"
        
        return matchData;
    }
    
    var messageDictionary:Dictionary<String, AnyObject> {
        var data:[String:AnyObject]    = [String:AnyObject]()
        var team:[String:AnyObject]    = [String:AnyObject]()
        var final:[String:AnyObject]   = [String:AnyObject]()
        
        // Team Info
        team["teamNumber"]  = teamNumber           as AnyObject?
        team["matchNumber"] = matchNumber          as AnyObject?
        team["alliance"]    = alliance.toString()  as AnyObject?
        
        // Final Info
        final["score"]      = finalScore           as AnyObject?
        final["rPoints"]    = finalRankingPoints   as AnyObject?
        final["result"]     = finalResult.toString() as AnyObject?
        final["pScore"]     = finalPenaltyScore    as AnyObject?
        final["fouls"]      = finalFouls           as AnyObject?
        final["tFouls"]     = finalTechFouls       as AnyObject?
        final["yCards"]     = finalYellowCards     as AnyObject?
        final["rCards"]     = finalRedCards        as AnyObject?
        final["robot"]      = finalRobot.toString()  as AnyObject?
        final["comments"]   = finalComments        as AnyObject?
        
        // All Data
        data["team"]        = team  as AnyObject?
        data["final"]       = final as AnyObject?
        
        return data
    }
    
    var encodingHelper: MatchEncodingHelper {
        return MatchEncodingHelper(match: self)
    }
    
    required init() {
        // Init
    }
    
    required init(queueData:MatchQueueData) {
        teamNumber = queueData.teamNumber
        matchNumber = queueData.matchNumber
        alliance = queueData.alliance
    }
    
    required init(withPList pList:[String:AnyObject]) {
        guard let team  = pList["team"]  as? [String:AnyObject],
            let final = pList["final"] as? [String:AnyObject] else {
                return
        }
        
        // Team Info
        teamNumber         = team["teamNumber"]  as! Int
        matchNumber        = team["matchNumber"] as! Int
        alliance           = AllianceType(rawValue: team["alliance"] as! Int)!
        isCompleted        = team["isCompleted"] as! Int
        
        // Final Info
        finalScore         = final["score"]      as! Int
        finalRankingPoints = final["rPoints"]    as! Int
        finalResult        = ResultType(rawValue: final["result"] as! Int)!
        finalPenaltyScore  = final["pScore"]     as! Int
        finalFouls         = final["fouls"]      as! Int
        finalTechFouls     = final["tFouls"]     as! Int
        finalYellowCards   = final["yCards"]     as! Int
        finalRedCards      = final["rCards"]     as! Int
        finalRobot         = RobotState(rawValue: final["robot"] as! Int)
        finalComments      = final["comments"]   as! String
    }
    
    // Required Functions
    func updateForType(_ type:UpdateType, withMatch match:Match) {
        fatalError("This method has not been implemented!")
    }
    
    func aggregateMatchData() {
        fatalError("This method has not been implemented!")
    }
    
}

extension MatchImpl: Equatable {
    static func ==(lhs:MatchImpl, rhs:MatchImpl) -> Bool {
        return lhs.matchNumber == rhs.matchNumber && lhs.teamNumber == rhs.teamNumber;
    }
}
