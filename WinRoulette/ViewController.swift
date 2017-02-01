//
//  ViewController.swift
//  WinRoulette
//
//  Created by Manoj Vemula on 2/26/16.
//  Copyright © 2016 Manoj Vemula. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var enterNumbersTextField: UITextField!
    @IBOutlet var gameNumberTextView: UITextView!
    @IBOutlet var winRouletteLabel: UILabel!
    @IBOutlet var colorWinLabel: UILabel!
    @IBOutlet var numbicTypeWinLabel: UILabel!
    @IBOutlet var heightForGameNumber: NSLayoutConstraint!
    var myGame: Roulette!
    
    @IBAction func getDistance() {
        if let exists = self.myGame.getDistanceBetween(self.myGame.currentGameNumbers[self.myGame.currentGameNumbers.count - 2], next: self.myGame.currentGameNumbers.last!) {
            self.winRouletteLabel.text = "Distance is \(exists)"
        } else {
            self.winRouletteLabel.text = "Cannot calculate Distance"
        }
    }
    
    @IBAction func getNextWinningNumber() {
        let winning = self.myGame.getNextExpectedNumber()
        let random = self.myGame.getRandomRouletteNumber()
        if winning.contains(random) || self.myGame.lastNumberIsExpectedColor() || self.myGame.lastNumberIsExpectedNumberType() {
          self.winRouletteLabel.backgroundColor = UIColor.greenColor()
        } else {
            self.winRouletteLabel.backgroundColor = UIColor.redColor()
        }
        self.winRouletteLabel.text = "W: \(winning.debugDescription)"
        self.gameNumberTextView.text = "Game Numbers : \(self.myGame.currentGameNumbers.description)"
        self.colorWinLabel.text = self.myGame.getExpectedColor()
        self.colorWinLabel.backgroundColor = self.myGame.getExpectedColor() == "red" ? UIColor.redColor() : UIColor.blackColor()
        self.numbicTypeWinLabel.text = self.myGame.getExpectedNumberType()
        //self.improvingAccuracy()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.myGame = Roulette()
        self.heightForGameNumber.constant = 300.0
        self.gameNumberTextView.text = "Game Numbers : \(self.myGame.currentGameNumbers.description)"
        //self.improvingAccuracy()
    }
    
    func improvingAccuracy() {
        var accuracyCounter = 0
        for _ in 1...100 {
            let winning = self.myGame.getNextExpectedNumber()
            let random = self.myGame.getRandomRouletteNumber()
            if winning.contains(random) {
                accuracyCounter++
            } else {
                for each in winning {
                    if self.myGame.findAccuracy(random, winning: each) <= 1  {
                        accuracyCounter++
                    }
                }
            }
        }
        self.winRouletteLabel.text = "Accuracy is \(accuracyCounter)%"
    }
}

extension ViewController {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if let isValidText = textField.text {
            if self.myGame.sortedRouletteNumbers.contains(isValidText) {
                self.myGame.currentGameNumbers.append(isValidText)
            } else {
                print("Invalid Entry")
            }
        }
        self.enterNumbersTextField.text = ""
        
        self.gameNumberTextView.text = "Game Numbers : \(self.myGame.currentGameNumbers.description)"
        return true
    }
}

