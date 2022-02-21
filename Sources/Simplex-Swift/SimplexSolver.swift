//
//  SimplexSolver.swift
//  Simplex-Swift
//
//  Created by Evgeny Seliverstov on 20/02/2022.
//

import Foundation

public class SimplexSolver {

    private init() {
        fatalError()
    }
    
    /// Finds the maximum value of the function with the given constraints.
    /// - Parameters:
    ///   - function: The function to maximize.
    ///     Example: `7x_1 + 8x_2 + 10x_3` is `[7, 8, 10]`
    ///   - constraints: Constraints of the given function.
    ///     Example:
    ///     ```
    ///     2x_1 + 3x_2 + 2x_3 ≤ 1000
    ///     x_1  + x_2  + 2x_3 ≤ 800
    ///     ```
    ///     is  `[[2, 3, 2, 1000], [1, 1, 2, 800]]`
    ///   - maximumIterationsCount: Maximum number of iterations to find a solution.
    /// - Returns: An array with variable values and the maximum value of the function.
    ///   Example: `200x_1 + 0x_2 + 300x_3 = 4400` is `[200, 0, 300, 4400]`
    /// - Complexity: Operations O(N), where N – maximumIterationsCount.
    ///   Memory O(M×N), where M – number of function variables, N – number of constraints.
    public static func maximize(function: [Double], constraints: [[Double]], maximumIterationsCount: Int) -> [Double]? {
        
        guard let solution = SimplexSolver.findSolutionForMaximizationProblem(function: function, constraints: constraints, maximumIterationsCount: maximumIterationsCount) else { return nil }
        guard let size = solution.table.first?.count, size > 2 else { return nil }
        
        // Extract the values of variables from the solution
        //
        // Example:
        //
        //    x1   x2   x3   s1  s2 p
        //    +----------------------------+
        //  x1|1    2   0    1  -1  0  200 |
        //    |                            |
        //  x3|0  -0.5  1  -0.5  1  0  300 |
        //    |                            |
        //   p|0    1   0    2   3  1  4400|
        //    +----------------------------+
        //
        // x1 = 200, x2 = 0, x3 = 300, p = 4400
        
        var variablesMap: [String: Double] = [:]
        for (index, row) in solution.table.enumerated() {
            guard let value = row.last else { return nil }
            variablesMap[solution.rowLabels[index]] = value
        }
        
        var result: [Double] = []
        for i in 0...function.count - 1 {
            guard let value = variablesMap["x\(i)"] else {
                result.append(0)
                continue
            }
            result.append(value)
        }
        result.append(solution.table.last?.last ?? 0)
        return result
    }
    
    /// Finds the minimum value of the function with the given constraints.
    /// - Parameters:
    ///   - function: The function to minimize.
    ///     Example: `3x_1 + 9x_2` is `[3, 9]`
    ///   - constraints: Constraints of the given function.
    ///     Example:
    ///     ```
    ///     2x_1 + x_2  ≥ 8
    ///     x_1  + 2x_2 ≥ 8
    ///     ```
    ///     is  `[[2, 1, 8], [1, 2, 8]]`
    ///   - maximumIterationsCount: Maximum number of iterations to find a solution.
    /// - Returns: An array with variable values and the minimum value of the function.
    ///   Example: `8x_1 + 0x_2 = 24` is `[8, 0, 24]`
    /// - Complexity: Operations O(N), where N – maximumIterationsCount.
    ///   Memory O(M×N), where M – number of function variables, N – number of constraints.
    public static func minimize(function: [Double], constraints: [[Double]], maximumIterationsCount: Int) -> [Double]? {
        
        // Transform the minimization problem into the maximization problem
        //
        // Example:
        // Given min(F)
        // 3x_1 + 9x_2 = F
        // 2x_1 + 1x_2 ≥ 8
        // 1x_1 + 2x_2 ≥ 8
        //
        // Become max(P)
        // 8y_1 + 8y_2 = P
        // 2y_1 + 1y_2 ≤ 3
        // 1y_1 + 2y_2 ≤ 9
        var functionRow = function
        functionRow.append(0)
        var matrix = constraints
        matrix.append(functionRow)
        
        guard var transposedMaxtix = transpose(matrix) else { return nil }
        guard var functionForMaximize = transposedMaxtix.last else { return nil }
        functionForMaximize.removeLast()
        transposedMaxtix.removeLast()
        let constraintsForMaximize = transposedMaxtix
        
        guard let solution = SimplexSolver.findSolutionForMaximizationProblem(function: functionForMaximize, constraints: constraintsForMaximize, maximumIterationsCount: maximumIterationsCount) else { return nil }
        guard let solutionRow = solution.table.last else { return nil }
        
        // Extract the values of variables from the solution
        //
        // Example:
        //
        //     x1   x2   s1   s2   p
        //    +---------------------------+
        //  x2| 2   1    1    0    0   3  |
        //    |                           |
        //  s2|-3   0   -2    1    0   3  |
        //    |                           |
        //   p| 8   0    8    0    1   24 |
        //    +---------------------------+
        //
        // x1 = 8, x2 = 0, f = 24
        
        var result: [Double] = []
        for i in functionForMaximize.count...solution.columnLabels.count - 2 {
            result.append(solutionRow[i])
        }
        result.append(solutionRow.last ?? 0)
        return result
    }
    
    /// Returns solved table with row and column labels
    ///
    /// Example:
    ///```
    ///    x1   x2   x3   s1  s2 p
    ///    +----------------------------+
    ///  x1|1    2   0    1  -1  0  200 |
    ///    |                            |
    ///  x3|0  -0.5  1  -0.5  1  0  300 |
    ///    |                            |
    ///   p|0    1   0    2   3  1  4400|
    ///    +----------------------------+
    ///```
    internal static func findSolutionForMaximizationProblem(function: [Double], constraints: [[Double]], maximumIterationsCount: Int) -> (table: [[Double]], rowLabels: [String], columnLabels: [String])? {
        
        // Transform the function into equation to zero
        // Example:
        //  7x_1 + 8X_2 + 10x_3 = p
        // -7x_1 - 8X_2 - 10x_3 + p = 0
        //
        // [7, 8, 10] -> [-7, -8, -10]
        let zeroFunction = function.map ({ -$0 })
        
        // Create initial table
        // Example:
        // -7x_1 - 8X_2 - 10x_3 + p  = 0
        //  2x_1 + 3x_2 + 2x_3  + s1 = 1000
        //  1x_1 + 1x_2 + 2x_3  + s2 = 800
        //
        //    x1   x2   x3   s1  s2 p
        //    +----------------------------+
        //  s1|2    3   2    1   0  0  1000|
        //    |                            |
        //  s2|1    1   2    0   1  0   800|
        //    |                            |
        //   p|-7  -8  -10   0   0  1     0|
        //    +----------------------------+
        guard var table = SimplexSolver.convertIntoTable(function: zeroFunction, constraints: constraints) else { return nil }
        var rowLabels = (0...constraints.count - 1).map ({ "s\($0)" })
        var columnLabels = (0...function.count - 1).map ({ "x\($0)" })
        columnLabels += (0...constraints.count - 1).map ({ "s\($0)" })
        columnLabels += ["p"]
        rowLabels += ["p"]
        
        var currentIteration = 0
        
        while !SimplexSolver.isSolved(table: table) && currentIteration < maximumIterationsCount {
            currentIteration += 1
            
            guard let pivot = SimplexSolver.getPivot(table: table) else { return nil }
            guard let newTable = SimplexSolver.performOptimizationStep(table: table) else { return nil }
        
            table = newTable
            rowLabels[pivot.row] = columnLabels[pivot.column]
        }
        
        guard SimplexSolver.isSolved(table: table) else { return nil }
        return (table: table, rowLabels: rowLabels, columnLabels: columnLabels)
    }
    
    internal static func performOptimizationStep(table: [[Double]]) -> [[Double]]? {
        
        guard let pivot = SimplexSolver.getPivot(table: table) else { return nil }
        
        var resultTable = table
        
        let pivotElement = table[pivot.row][pivot.column]
        
        resultTable[pivot.row] = SimplexSolver.divideRow(rowElements: resultTable[pivot.row], value: pivotElement)
        
        for i in 0...table.count - 1 {
            guard i != pivot.row else { continue }

            let rowForAdd = SimplexSolver.multiplyRow(rowElements: resultTable[pivot.row], value: -resultTable[i][pivot.column])
            
            resultTable[i] = SimplexSolver.sumRows(firstRowElements: resultTable[i], secondRowElements: rowForAdd)
        }
        
        return resultTable
    }
    
    /// Returns the pivot element row and column index
    ///
    /// Example:
    ///```
    /// +----------------------------+
    /// |2    3   2    1   0  0  1000| 1000/2 = 500
    /// |                            |
    /// |1    1  |2|   0   1  0   800| 800/2  = 400
    /// |                            |
    /// |-7  -8  -10   0   0  1     0|
    /// +----------------------------+
    ///           ^
    ///```
    /// The most negative element in the last row is -10, therefore pivot column index is 2.
    /// The smallest division of function element by element at the index of the pivot column is 400, therefore pivot row index is 1.
    /// Returns: (2, 1)
    internal static func getPivot(table: [[Double]]) -> (column: Int, row: Int)? {
        
        guard var lastRow = table.last else { return nil }
        lastRow.removeLast()
        guard let minValueInLastRow = lastRow.min() else { return nil }
        guard let pivotColumn = table.last?.firstIndex(of: minValueInLastRow) else { return nil }
        
        var values = table.compactMap { row -> Double in
            guard let last = row.last, last != 0 else { return 0 }
            return last / row[pivotColumn]
        }
        values.removeLast()
        
        guard let pivotNumber = values.min() else { return nil }
        guard let pivotRow = values.firstIndex(of: pivotNumber) else { return nil }
        
        return (pivotColumn, pivotRow)
    }
    
    /// Convert the function with constraints into a table
    ///
    /// Example:
    ///
    /// Function: `[-7, -8, -10]`,  constraints: `[[2, 3, 2, 1000], [1, 1, 2, 800]]`
    ///```
    /// +----------------------------+
    /// |2    3   2    1   0  0  1000|
    /// |                            |
    /// |1    1   2    0   1  0   800|
    /// |                            |
    /// |-7  -8  -10   0   0  1     0|
    /// +----------------------------+
    ///```
    /// Returns:
    /// ```
    /// [2, 3, 2, 1, 0, 0, 1000]
    /// [1, 1, 2, 0, 1, 0, 800]
    /// [-7, -8, -10, 0, 0, 1, 0]
    /// ```
    internal static func convertIntoTable(function: [Double], constraints: [[Double]]) -> [[Double]]? {
        
        let numberOfSlackVariables = constraints.count
        let numberOfSubjectVariables = (constraints.first?.count ?? 0) - 1
        
        guard numberOfSlackVariables >= 1, numberOfSubjectVariables >= 2 else { return nil }
        
        var result: [[Double]] = []
        
        for (index, _) in constraints.enumerated() {

            var row: [Double] = constraints[index]
            
            while row.count < numberOfSubjectVariables {
                row.insert(0.0, at: row.count - 2)
            }
            
            var slackVariables: [Double] = Array(repeating: 0.0, count: numberOfSlackVariables + 1)
            slackVariables[index] = 1
            row.insert(contentsOf: slackVariables, at: row.count - 1)
            
            result.append(row)
        }
        
        var functionRow: [Double] = function
        functionRow += Array(repeating: 0.0, count: numberOfSlackVariables)
        functionRow += [1.0, 0.0]
        
        result.append(functionRow)
        return result
    }
    
    internal static func isSolved(table: [[Double]]) -> Bool {
        guard let lastRow = table.last else { return false }
        return !(lastRow.filter { $0 < 0 }.count > 0)
    }
    
    /// Transpose two dimensional array
    ///
    /// Example:
    /// ```
    /// [1,   2,  3]
    /// [4,   5,  6]
    /// [7,   8,  9]
    /// [10, 11,  12]
    /// ```
    /// Returns:
    /// ```
    /// [1, 4, 7, 10]
    /// [2, 5, 8, 11]
    /// [3, 6, 9, 12]
    /// ```
    internal static func transpose(_ array: [[Double]]) -> [[Double]]? {
        
        guard Set(array.map({ $0.count })).count == 1 else { return nil }
        guard let firstRow = array.first else { return nil }
        
        let transposedValue = firstRow.indices.map { index in
            array.map{ $0[index] }
        }
        
        return transposedValue
    }
    
    internal static func multiplyRow(rowElements: [Double], value: Double) -> [Double] {
        
        return rowElements.map { $0 * value }
    }
    
    internal static func divideRow(rowElements: [Double], value: Double) -> [Double] {
        
        return rowElements.map { $0 / value }
    }
    
    internal static func sumRows(firstRowElements: [Double], secondRowElements: [Double]) -> [Double] {
        
        var result: [Double] = []
        for (index, _) in firstRowElements.enumerated() {
            result.append(firstRowElements[index] + secondRowElements[index])
        }
        
        return result
    }
}
