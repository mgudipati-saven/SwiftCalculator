//
//  CalculatorModel.swift
//  Calculator
//
//  Created by Murty Gudipati on 2/24/15.
//  Copyright (c) 2015 Murty Gudipati. All rights reserved.
//

import Foundation

class CalculatorModel: Printable
{
    private enum Op: Printable
    {
        case Operand(Double)
        case Variable(String)
        case Constant(String, () -> Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .Variable(let symbol):
                    return symbol
                case .Constant(let symbol, _):
                    return symbol
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                }
            }
        }
    }
    
    private var opStack = [Op]()
    
    private var knownOps = [String:Op]()
    
    init()
    {
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        
        learnOp(Op.BinaryOperation("×", *))
        learnOp(Op.BinaryOperation("÷") { $1 / $0 })
        learnOp(Op.BinaryOperation("+", +))
        learnOp(Op.BinaryOperation("−") { $1 - $0 })
        learnOp(Op.UnaryOperation("√", sqrt))
        learnOp(Op.UnaryOperation("cos", cos))
        learnOp(Op.UnaryOperation("sin", sin))
        learnOp(Op.UnaryOperation("±", -))
        learnOp(Op.Constant("π") {M_PI})
    }

    var description: String {
        get {
            var desc = [String]()
            var ops = opStack
            do {
                var exp = expression(ops)
                if exp.result != nil {
                    desc.append(exp.result!)
                    ops = exp.remainingOps
                } else {
                    break
                }
            } while !ops.isEmpty
            
            var result = ""
            for (index, value) in enumerate(desc.reverse()) {
                if index == 0 {
                    result += value
                } else {
                    result += ", " + value
                }
            }
            return result
        }
    }
        
    private func expression(ops: [Op]) -> (result: String?, remainingOps: [Op])
    {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return ("\(operand)", remainingOps)
            case .Variable(let symbol):
                return (symbol, remainingOps)
            case .Constant(let symbol, _):
                return (symbol, remainingOps)
            case .UnaryOperation(let symbol, _):
                let opExpression = expression(remainingOps)
                if let operand = opExpression.result {
                    return (symbol + "(\(operand))", opExpression.remainingOps)
                } else {
                    return (symbol + "(?)", opExpression.remainingOps)
                }
            case .BinaryOperation(let symbol, _):
                let op1Expression = expression(remainingOps)
                if let op1 = op1Expression.result {
                    let op2Expression = expression(op1Expression.remainingOps)
                    if let op2 = op2Expression.result {
                        return ("(\(op2)\(symbol)\(op1))", op2Expression.remainingOps)
                    } else {
                        return ("(?\(symbol)\(op1))", op2Expression.remainingOps)
                    }
                } else {
                    return ("(?\(symbol)?)", op1Expression.remainingOps)
                }
            }
        }
        return (nil, ops)
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op])
    {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .Variable(let variable):
                return (variableValues[variable], remainingOps)
            case .Constant(_, let operation):
                return (operation(), remainingOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let operand1Evaluation = evaluate(remainingOps)
                if let operand1 = operand1Evaluation.result {
                    let operand2Evaluation = evaluate(operand1Evaluation.remainingOps)
                    if let operand2 = operand2Evaluation.result {
                        return (operation(operand1, operand2), operand2Evaluation.remainingOps)
                    }
                }
            }
        }
        return (nil, ops)
    }
    
    func clear()
    {
        opStack.removeAll(keepCapacity: true)
    }
    
    func undo() -> Double?
    {
        if !opStack.isEmpty {
            opStack.removeLast()
        }
        return evaluate()
    }
    
    func evaluate() -> Double?
    {
        let (result, remainder) = evaluate(opStack)
        return result
    }
    
    func pushOperand(operand: Double) -> Double?
    {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    var variableValues = [String:Double]()
    
    func pushOperand(symbol: String) -> Double?
    {
        opStack.append(Op.Variable(symbol))
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double?
    {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
}
