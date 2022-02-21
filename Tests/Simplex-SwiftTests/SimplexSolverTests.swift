//
//  SimplexSolverTests.swift
//  Simplex-SwiftTests
//
//  Created by Evgeny Seliverstov on 20/02/2022.
//

import XCTest
@testable import Simplex_Swift

final class SimplexSolverTests: XCTestCase {
    
    func testMaximize() throws {
        
        // Given
        
        let function   : [Double] = [7, 8, 10]
        let constraint1: [Double] = [2, 3, 2, 1000]
        let constraint2: [Double] = [1, 1, 2, 800]
        
        let resultSolution: [Double] = [200, 0, 300, 4400]
        
        // When
        
        let result = SimplexSolver.maximize(function: function, constraints: [constraint1, constraint2], maximumIterationsCount: 10)
        
        // Then
        
        XCTAssertEqual(result, resultSolution)
    }
    
    func testMinimize() throws {
        
        // Given
        
        let function   : [Double] = [3, 9]
        let constraint1: [Double] = [2, 1, 8]
        let constraint2: [Double] = [1, 2, 8]
        
        let resultSolution: [Double] = [8, 0, 24]
        
        // When
        
        let result = SimplexSolver.minimize(function: function, constraints: [constraint1, constraint2], maximumIterationsCount: 10)
        
        // Then
        
        XCTAssertEqual(result, resultSolution)
    }
    
    func testConvertIntoTable() throws {
        
        // Given
        
        let function   : [Double] = [-7, -8, -10]
        let constraint1: [Double] = [2, 3, 2, 1000]
        let constraint2: [Double] = [1, 1, 2, 800]
        
        let resultTableRow1: [Double] = [2, 3, 2, 1, 0, 0, 1000]
        let resultTableRow2: [Double] = [1, 1, 2, 0, 1, 0, 800]
        let resultTableRow3: [Double] = [-7, -8, -10, 0, 0, 1, 0]
        
        // When
        
        let result = SimplexSolver.convertIntoTable(function: function, constraints: [constraint1, constraint2])
        
        // Then
        
        XCTAssertEqual(result, [resultTableRow1, resultTableRow2, resultTableRow3])
    }
    
    func testPerformOptimizationStep() throws {
        
        // Given
        
        let tableRow1: [Double] = [2, 3, 2, 1, 0, 0, 1000]
        let tableRow2: [Double] = [1, 1, 2, 0, 1, 0, 800]
        let tableRow3: [Double] = [-7, -8, -10, 0, 0, 1, 0]
        
        let optimizeResultRow1: [Double] = [1, 2, 0, 1, -1, 0, 200]
        let optimizeResultRow2: [Double] = [0.5, 0.5, 1, 0, 0.5, 0, 400]
        let optimizeResultRow3: [Double] = [-2, -3, 0, 0, 5, 1, 4000]
        
        // When
        
        let result = SimplexSolver.performOptimizationStep(table: [tableRow1, tableRow2, tableRow3])
        
        // Then
        XCTAssertEqual(result, [optimizeResultRow1, optimizeResultRow2, optimizeResultRow3])
    }
    
    func testGetPivot() throws {
        
        // Given
        
        let tableRow1: [Double] = [2, 3, 2, 1, 0, 0, 1000]
        let tableRow2: [Double] = [1, 1, 2, 0, 1, 0, 800]
        let tableRow3: [Double] = [-7, -8, -10, 0, 0, 1, 0]
        
        // When
        
        let pivot = SimplexSolver.getPivot(table: [tableRow1, tableRow2, tableRow3])
        
        // Then
        
        XCTAssertEqual(pivot?.row, 1)
        XCTAssertEqual(pivot?.column, 2)
    }
    
    func testTranspose() throws {
        
        // Given

        let value: [[Double]] = [[1,   2,  3],
                                 [4,   5,  6],
                                 [7,   8,  9],
                                 [10, 11,  12]]

        let resultValue: [[Double]] = [[1, 4, 7, 10],
                                       [2, 5, 8, 11],
                                       [3, 6, 9, 12]]
        
        // When
        
        let result = SimplexSolver.transpose(value)
        
        // Then
        
        XCTAssertEqual(result, resultValue)
    }
}
