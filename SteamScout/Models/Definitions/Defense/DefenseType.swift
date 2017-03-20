//
//  DefenseType.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 3/19/17.
//  Copyright © 2017 dhanwada. All rights reserved.
//

import Foundation

enum DefenseType:Int {
    case unknown = 0, portcullis, chevaldefrise, moat, ramparts, drawbridge, sallyport, rockwall, roughterrain, lowbar
    
    func complementType() -> DefenseType {
        return (self == .portcullis) ? .chevaldefrise :
            (self == .chevaldefrise) ? .portcullis :
            (self == .moat) ? .ramparts :
            (self == .ramparts) ? .moat :
            (self == .drawbridge) ? .sallyport :
            (self == .sallyport) ? .drawbridge :
            (self == .rockwall) ? .roughterrain :
            (self == .roughterrain) ? .rockwall : .unknown
    }
    
    func toString() -> String! {
        return (self == .portcullis) ? "portcullis" :
            (self == .chevaldefrise) ? "chevaldefrise" :
            (self == .moat) ? "moat" :
            (self == .ramparts) ? "ramparts" :
            (self == .drawbridge) ? "drawbridge" :
            (self == .sallyport) ? "sallyport" :
            (self == .rockwall) ? "rockwall" :
            (self == .roughterrain) ? "roughterrain" :
            (self == .lowbar) ? "lowbar" : "unknown"
    }
    
    func toStringResults() -> String {
        return (self == .portcullis) ? "Portcullis" :
            (self == .chevaldefrise) ? "Cheval de Frise" :
            (self == .moat) ? "Moat" :
            (self == .ramparts) ? "Ramparts" :
            (self == .drawbridge) ? "Drawbridge" :
            (self == .sallyport) ? "Sallyport" :
            (self == .rockwall) ? "Rock Wall" :
            (self == .roughterrain) ? "Rough Terrain" :
            (self == .lowbar) ? "Low Bar" : "Unknown"
    }
}
