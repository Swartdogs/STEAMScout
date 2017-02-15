//
//  Match.swift
//  StrongScout
//
//  Created by Srinivas Dhanwada on 2/6/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import UIKit
import SwiftyJSON

class Match : NSObject {
    
    // Team Info
    
    var teamNumber:Int = -1
    var matchNumber:Int = -1
    var alliance:AllianceType = .unknown
    var isCompleted:Int = 32
    
    // Final Info
    
    var finalScore:Int = -1
    var finalRankingPoints:Int = -1
    var finalResult:ResultType = .none
    var finalPenaltyScore:Int = 0
    var finalFouls = 0
    var finalTechFouls = 0
    var finalYellowCards = 0
    var finalRedCards = 0
    var finalRobot:RobotState = .None
    var finalConfiguration:FinalConfigType = .none
    var finalComments = ""
    
    override init() {
        // init
    }
    
    init(queueData:MatchQueueData) {
        self.matchNumber = queueData.matchNumber
        self.teamNumber  = queueData.teamNumber
        self.alliance    = queueData.alliance
    }
}
