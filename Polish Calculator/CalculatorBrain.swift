//
//  CalculatorBrain.swift
//  Calculator Walkthrough
//
//  Created by Michael Perry on 9/12/15.
//  Copyright © 2015 Michael Perry. All rights reserved.
//

import Darwin
import Foundation

//CustomStringConvertible protocol is imported to force description variable implementation
class CalculatorBrain: CustomStringConvertible {
    
    //Op enum that handles differnet possible inputs of operands and operations
    private enum Op: CustomStringConvertible {
        case Operand (Double)
        case UnaryOperation (String, Double -> Double)
        case BinaryOperation (String, (Double, Double) -> Double)
        case PieOperation (String, Double)
        
        var description: String {
            switch self {
            case .Operand(let operand):
                return "\(operand)"
            case .UnaryOperation(let symbol, _):
                return symbol
            case .BinaryOperation(let symbol, _):
                return symbol
            case .PieOperation(let symbol, _):
                return symbol
            }
        }
    }
    
    //stack that contains all operands and operations for computation
    private var opStack = [Op]()
    
    //dictionary for signed operations
    private var knownOps = [String : Op]()
    
    //fill up the knownOps stack with operations and constants needed for our calculator
    init () {
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        
        learnOp(Op.BinaryOperation("×", *))
        learnOp(Op.BinaryOperation("÷") { $1 / $0 })
        learnOp(Op.BinaryOperation("+", +))
        learnOp(Op.BinaryOperation("-") { $1 - $0 })
        learnOp(Op.UnaryOperation("√", sqrt))
        learnOp(Op.PieOperation("π", M_PI))
        learnOp(Op.UnaryOperation("sin", sin))
        learnOp(Op.UnaryOperation("cos", cos))
    }
    
    //this is a recursive function that goes through all stack values and lays out the operations in string form
    private func setDescription (ops: [Op]) -> (result: String, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            
            switch op {
            case .Operand(let operand):
                return (String(operand), remainingOps)
            case .UnaryOperation(let symbol, _):
                let operandEvaluation = setDescription(remainingOps)
                
                if let operand: String = operandEvaluation.result {
                    return ("\(symbol) (\(operand))", operandEvaluation.remainingOps)
                }
            case .BinaryOperation(let symbol, _):
                let op1Evaluation = setDescription(remainingOps)
                
                if let operand1: String = op1Evaluation.result {
                    let op2Evaluation = setDescription(op1Evaluation.remainingOps)
                    
                    if let operand2: String = op2Evaluation.result {
                        if op2Evaluation.remainingOps.count == 0 {
                            return ("\(operand2) \(symbol) \(operand1)", op2Evaluation.remainingOps)
                        } else {
                            return ("(\(operand2) \(symbol) \(operand1))", op2Evaluation.remainingOps)
                        }
                    }
                }
            case .PieOperation(let symbol, _):
                return (symbol, remainingOps)
            }
        }
        return ("?", ops)
    }
    
    //return the written out formula for the answer being computed
    //the while loop jumps through each operation available in the stack
    //each seperate operation is seperated by a comma
    //if there is only on operation that involves all values in the stack then there will be no comma added
    internal var description: String {
        
        if !opStack.isEmpty {
            var stack = opStack
            var result = ""
            var needsComma = false
            
            while !stack.isEmpty {
                if needsComma {
                    result = " , " + result
                }
                
                let answer = setDescription(stack)
                result =  answer.result + result
                stack = answer.remainingOps
                needsComma = true
            }
            return result
        }
        return ""
    }
    

    //recursive function that computes all operations in the stack
    //first check opStack for values
    //then pop each op off of the stack and preform operation on values
    //ignore values that don't have an associated operator
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let op1Evaluation = evaluate(remainingOps)
                
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            case .PieOperation(_, let operand):
                return (operand, remainingOps)
            }
        }
        
        return (0, ops)
    }
    
    //return computed value for operation
    func evaluate() -> Double? {
        let (result, _) = evaluate(opStack)

        return result
    }
    
    //add and perform operation on stack values
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        
        return evaluate()
    }
    
    //add operand to stack
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        
        return evaluate()
    }
    
    func clear() {
        opStack.removeAll()
    }
}
