//
//  Match.swift
//  StrongScout
//
//  Created by Srinivas Dhanwada on 2/6/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol Match : NSCoding {
    
    // Team Info
    
    var teamNumber:Int { get set }
    var matchNumber:Int { get set }
    var alliance:AllianceType { get set }
    var isCompleted:Int { get set }
    
    // Final Info
    
    var finalScore:Int { get set }
    var finalRankingPoints:Int { get set }
    var finalResult:ResultType { get set }
    var finalPenaltyScore:Int  { get set }
    var finalFouls:Int { get set }
    var finalTechFouls:Int { get set }
    var finalYellowCards:Int { get set }
    var finalRedCards:Int { get set }
    var finalRobot:RobotState { get set }
    var finalComments:String { get set }
    
    // Calculated Variables
    static var csvHeader:String { get }
    var csvMatch:String { get }
    var messageDictionary:NSDictionary { get }
    
    init(queueData:MatchQueueData)
    
    // Required Functions
    func updateMatchForType(_ type:UpdateType, match:Match)
    func updateMatchWithAction(_ action:Action)
    func aggregateActionsPerformed()
    func aggregateMatchData()
    
}
