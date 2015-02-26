//
//  ViewController.swift
//  Calculator
//
//  Created by Murty Gudipati on 2/22/15.
//  Copyright (c) 2015 Murty Gudipati. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    @IBOutlet weak var display: UILabel!

    @IBOutlet weak var history: UILabel!
    
    var userIsInTheMiddleOfTypingANumber = false

    // The model
    var calc = CalculatorModel()
    
    @IBAction func appendDigit(sender: UIButton)
    {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber {
            if (digit == "." && display.text!.rangeOfString(".") != nil) {
            } else {
                display.text = display.text! + digit
            }
        } else {
            display.text = digit
            userIsInTheMiddleOfTypingANumber = true
        }
    }
        
    @IBAction func clear()
    {
        userIsInTheMiddleOfTypingANumber = false
        calc.clear()
        calc.variableValues.removeValueForKey("M")
        displayValue = nil
        historyValue = nil
    }
    
    // backspace or undo
    @IBAction func backspace()
    {
        if userIsInTheMiddleOfTypingANumber {
            // backspace
            display.text = dropLast(display.text!)
            var numElements = countElements(display.text!)
            if numElements == 0
            {
                display.text = "0"
                userIsInTheMiddleOfTypingANumber = false
            }
        } else {
            // undo
            displayValue = calc.undo()
            historyValue = "\(calc)"
        }
    }
    
    @IBAction func operate(sender: UIButton)
    {
        let operation = sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber {
            if operation == "±"
            {
                displayValue = displayValue! * -1.0
                userIsInTheMiddleOfTypingANumber = true
                return
            } else {
                enter()
            }
        }

        displayValue = calc.performOperation(operation)
        historyValue = "\(calc)"
    }

    @IBAction func getmem() {
        displayValue = calc.pushOperand("M")
    }
    
    @IBAction func setmem() {
        if displayValue != nil {
            calc.variableValues["M"] = displayValue!
            displayValue = calc.evaluate()
            userIsInTheMiddleOfTypingANumber = false
        }
    }
    
    @IBAction func enter()
    {
        userIsInTheMiddleOfTypingANumber = false
        displayValue = calc.pushOperand(displayValue!)
        historyValue = "\(calc)"
    }
    
    var historyValue: String?
    {
        get {
            return "\(calc)"
        }
        set {
            if newValue != nil {
                history.text = "\(newValue!) ="
            }
            else {
                history.text = " "
            }
        }
    }
    
    var displayValue: Double?
    {
        get {
            if let value = NSNumberFormatter().numberFromString(display.text!)?.doubleValue {
                return value
            }
            else {
                return nil
            }
        }
        set {
            if newValue != nil {
                display.text = "\(newValue!)"
            }
            else {
                display.text = "0"
            }
            userIsInTheMiddleOfTypingANumber = false
        }
    }
}

