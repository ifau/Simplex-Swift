# Simplex-Swift

This package contains a basic implementation of the [Simplex algorithm](https://en.wikipedia.org/wiki/Simplex_algorithm).

# Usage

### 1. Solving maximization problem

For [example](https://www.youtube.com/watch?v=gRgsT9BB5-8), given a function with constraints:

F = 7X<sub>1</sub> + 8X<sub>2</sub> + 10X<sub>3</sub>

2X<sub>1</sub> + 3X<sub>2</sub> + 2X<sub>3</sub> ≤ 1000

X<sub>1</sub> + X<sub>2</sub> + 2X<sub>3</sub> ≤ 800

We need to maximize F(X<sub>1</sub> X<sub>2</sub> X<sub>3</sub>).

```swift
let function    : [Double] = [7, 8, 10]
let constraint1 : [Double] = [2, 3, 2, 1000]
let constraint2 : [Double] = [1, 1, 2, 800]

if let solution = SimplexSolver.maximize(function: function, constraints: [constraint1, constraint2], maximumIterationsCount: 10) {
    let x1 = solution[0]  // 200
    let x2 = solution[1]  // 0
    let x3 = solution[2]  // 300
    let f  = solution[3]  // 4400
}
```

The maximum value of the function F(X<sub>1</sub> X<sub>2</sub> X<sub>3</sub>) is 4400 when X<sub>1</sub> = 200, X<sub>2</sub> = 0, X<sub>3</sub> = 300.

### 2. Solving minimization problem

Another [example](https://www.youtube.com/watch?v=8_D3gkrgeK8), given a function with constraints:

F = 3X<sub>1</sub> + 9X<sub>2</sub>

2X<sub>1</sub> + X<sub>2</sub> ≥ 8

X<sub>1</sub> + 2X<sub>2</sub> ≥ 8

Minimize F(X<sub>1</sub> X<sub>2</sub>).

```swift
let function    : [Double] = [3, 9]
let constraint1 : [Double] = [2, 1, 8]
let constraint2 : [Double] = [1, 2, 8]

if let solution = SimplexSolver.minimize(function: function, constraints: [constraint1, constraint2], maximumIterationsCount: 10) {
    let x1 = solution[0]  // 8
    let x2 = solution[1]  // 0
    let f  = solution[2]  // 24
}
```

The minimum value of the function F(X<sub>1</sub> X<sub>2</sub>) is 24 when X<sub>1</sub> = 8, X<sub>2</sub> = 0.