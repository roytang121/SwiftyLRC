//
//  SwiftyLRC.swift
//  SwiftyRegex
//
//  Created by Roy Tang on 24/6/15.
//  Copyright © 2015 Roy Tang. All rights reserved.
//

import Foundation
import AVFoundation

class SwiftLRC {
    var debug: Bool! {
        didSet {
            self.debugMode()
        }
    }
    
    
    init() {
        
    }
    
    func debugMode() -> [LRCTuple]! {
        let path = NSBundle.mainBundle().pathForResource("test", ofType: "lrc")!
        do {
            let content = try String(contentsOfFile: path, encoding: NSUTF8StringEncoding)
            return SwiftLRC.parse(content)
        } catch _ {
            return nil
        }
    }
    
    func timeStampToTime(timeStamp: String) -> CMTime! {
        var str: String = timeStamp.stringByReplacingOccurrencesOfString("[", withString: "")
                                    .stringByReplacingOccurrencesOfString("]", withString: "")
        var tmp: [String] = str.componentsSeparatedByString(":")
        
//        print(tmp)
        return CMTimeMakeWithSeconds(Float64(tmp[0].floatValue() * 60.0 + tmp[1].floatValue()), 600)
    }
    
    static func parse(content: String) -> [LRCTuple]! {
        var array: [String] = content.componentsSeparatedByString("\n")
        var lrc: Array<LRCTuple> = Array()
        
        do {
            for val in array {
                var chomp: String = val.stringByReplacingOccurrencesOfString("\r", withString: "")
                
                var regex = try NSRegularExpression(pattern: "\\[\\d{2}:\\d{2}.\\d{2}\\]", options: NSRegularExpressionOptions.CaseInsensitive)
                
                let matches = regex.matchesInString(chomp, options: NSMatchingOptions.ReportProgress, range: NSMakeRange(0, chomp.characters.count))
                
                if matches.count > 0 {
                    
                    // find the lyrics str first
                    let last = matches.last! as NSTextCheckingResult
                    
                    let line = (chomp as NSString).substringWithRange(
                        NSMakeRange(last.range.location + last.range.length, chomp.characters.count - (last.range.location + last.range.length))
                    )
                    
                    for match in matches {
                        var temp = (chomp as NSString).substringWithRange(match.range)
                        var time = self.timeStampToTime(temp)
                        lrc.append((time, line))
                    }
                }
                
            }
            
            lrc.sortInPlace({ (left, right) -> Bool in
                return CMTimeCompare(left.0, right.0) == -1
            })
            
            return lrc
        } catch _ {
            return nil
        }
    }
}


extension String {
    func floatValue() -> Float {
        return (self as NSString).floatValue
    }
}

typealias LRCTuple = (start: CMTime, end: String)