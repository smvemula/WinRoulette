//
//  Roulette.swift
//  WinRoulette
//
//  Created by Manoj Vemula on 2/26/16.
//  Copyright © 2016 Manoj Vemula. All rights reserved.
//

import UIKit

class Roulette: NSObject {
    //0-28-9-26-30-11-7-20-32-17-5-22-34-15-3-24-36-13-1-00-27-10-25-29-12-8-19-31-18-6-21-33-16-4-23-35-14-2
    var sortedRouletteNumbers = ["0","28","9","26","30","11","7","20","32","17","5","22","34","15","3","24","36","13","1","00","27","10","25","29","12","8","19","31","18","6","21","33","16","4","23","35","14","2"];

    var currentGameNumbers = [String]()
    var frequencyForGameNumbers = [String: Int]()
    
    override init() {
        super.init()
        self.addRandomNumbers()
        self.frequencyForGameNumbers["red"] = 0
        self.frequencyForGameNumbers["black"] = 0
        self.frequencyForGameNumbers["odd"] = 0
        self.frequencyForGameNumbers["even"] = 0
    }
    
    
    func addRandomNumbers() {
        //self.currentGameNumbers = []
        for _ in 1...20 {
            self.getRandomRouletteNumber()
        }
    }
    
    func addNewGameNumber(rouletteNumber: String) {
        //Maintain frequency for numbers
        if let exists = self.frequencyForGameNumbers[rouletteNumber] {
            self.frequencyForGameNumbers[rouletteNumber] = exists + 1
        } else {
            self.frequencyForGameNumbers[rouletteNumber] = 1
        }
        
        //Main Even & Odd frequency
        if rouletteNumber != "0" && rouletteNumber != "00" {
            if let numeric = Int(rouletteNumber) {
                if numeric%2 == 0 {
                    if let exists = self.frequencyForGameNumbers["even"] {
                        self.frequencyForGameNumbers["even"] = exists + 1
                    }
                } else {
                    if let exists = self.frequencyForGameNumbers["odd"] {
                        self.frequencyForGameNumbers["odd"] = exists + 1
                    }
                }
            }
        }
        
        //Main Black & Red frequency
        if rouletteNumber != "0" && rouletteNumber != "00" {
            if let numeric = self.sortedRouletteNumbers.indexOf(rouletteNumber) {
                if numeric%2 == 0 {
                    if let exists = self.frequencyForGameNumbers["black"] {
                        self.frequencyForGameNumbers["black"] = exists + 1
                    }
                } else {
                    if let exists = self.frequencyForGameNumbers["red"] {
                        self.frequencyForGameNumbers["red"] = exists + 1
                    }
                }
            }
        }
        
        self.currentGameNumbers.insert(rouletteNumber, atIndex: 0)
    }
    
    func getRandomRouletteNumber() -> String {
        let randomRouletteNumber = self.sortedRouletteNumbers[Int(arc4random_uniform(UInt32(self.sortedRouletteNumbers.count)))]
        self.addNewGameNumber(randomRouletteNumber)
        return randomRouletteNumber
    }
    
    func getExpectedColor() -> String {
        if let black = self.frequencyForGameNumbers["black"] {
            if let red = self.frequencyForGameNumbers["red"] {
                return black > red ? "Black" : "Red"
            }
        }
        return "black"
    }
    
    func getExpectedNumberType() -> String {
        if let even = self.frequencyForGameNumbers["even"] {
            if let odd = self.frequencyForGameNumbers["odd"] {
                return even > odd ? "Even" : "Odd"
            }
        }
        return "even"
    }
    
    func lastNumberIsExpectedColor()-> Bool {
        if self.currentGameNumbers.first! != "0" && self.currentGameNumbers.first! != "00" {
            if let numeric = self.sortedRouletteNumbers.indexOf(self.currentGameNumbers.first!) {
                if numeric%2 == 0 {
                    return self.getExpectedColor() == "Black"
                } else {
                    return self.getExpectedColor() == "Red"
                }
            }
        }
        return false
    }
    
    func lastNumberIsExpectedNumberType()-> Bool {
        if self.currentGameNumbers.first! != "0" && self.currentGameNumbers.first! != "00" {
            if let numeric = Int(self.currentGameNumbers.first!) {
                if numeric%2 == 0 {
                    return self.getExpectedNumberType() == "Even"
                } else {
                    return self.getExpectedNumberType() == "Odd"
                }
            }
        }
        return false
    }
    
    func getNextExpectedNumber() -> [String] {
        var distanceCounter = [Int: Int]()
        for (index, each) in  EnumerateSequence(currentGameNumbers) {
            if index < self.currentGameNumbers.count - 2 {
                if let weCanFindDistance = self.getDistanceBetween(each, next: self.currentGameNumbers[index+1]) {
                    if let countExists = distanceCounter[weCanFindDistance] {
                        distanceCounter[weCanFindDistance] = countExists + 1
                    } else {
                        distanceCounter[weCanFindDistance] = 1
                    }
                }
            }
        }
        
        var mostExpected : Int?
        for (rouletteJumb, occurence) in distanceCounter {
            if let check = mostExpected {
                if occurence > distanceCounter[check] {
                    mostExpected = rouletteJumb
                }
            } else {
                mostExpected = rouletteJumb
            }
        }
        
        if let lastNumber = self.currentGameNumbers.first {
            if let foundMostOcurringDistance = mostExpected {
                if let prevIndex = self.sortedRouletteNumbers.indexOf(lastNumber) {
                    let nextNumberIndex = (prevIndex + foundMostOcurringDistance) > 37 ? (prevIndex + foundMostOcurringDistance) - 37: (prevIndex + foundMostOcurringDistance)
                    var expectedNumbers = [String]()
                    for index in nextNumberIndex - 4...nextNumberIndex + 3 {
                        if index < 0 {
                            expectedNumbers.append(self.sortedRouletteNumbers[37 + index])
                        } else if index > 37 {
                            expectedNumbers.append(self.sortedRouletteNumbers[index - 37])
                        } else {
                            expectedNumbers.append(self.sortedRouletteNumbers[index])
                        }
                    }
                    //return self.sortedRouletteNumbers[nextNumberIndex - 1]
                    
                    //add most repeated numbers
                    for (number, occurence) in self.frequencyForGameNumbers {
                        //change occurence level with numbers count
                        if let _ = Int(number) {
                            if occurence > Int(Float(self.currentGameNumbers.count)*0.1) && !expectedNumbers.contains(number) {
                                expectedNumbers.append(number)
                            }
                        }
                    }
                    return expectedNumbers
                }
            }
        }
        return []
    }
    
    func getDistanceBetween(current: String, next: String) -> Int? {
        if let currentExists = self.sortedRouletteNumbers.indexOf(current) {
            if let nextExists = self.sortedRouletteNumbers.indexOf(next) {
                if currentExists < nextExists {
                    return nextExists - currentExists
                } else {
                    return 37 - currentExists + nextExists
                }
            }
        }
        return nil
    }
    
    func findAccuracy(random: String, winning: String) -> Int {
        if let r = self.sortedRouletteNumbers.indexOf(random) {
            if let w = self.sortedRouletteNumbers.indexOf(winning) {
                if r > w {
                    return r-w
                }
                return w-r
            }
        }
        return 0
    }
}
