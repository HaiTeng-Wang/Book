# Swift Programming Language Notes

Quick reference based on [The Swift Programming Language (6.2.3)](https://doc.swiftgg.team/documentation/the-swift-programming-language).

## Basics, Basic Operators, Strings and Characters
Omitted — skim the documentation.

## Collection Types

Swift provides three primary collection types: `Array`, `Set`, `Dictionary`.

- **Array**: Ordered collection. Duplicates allowed.
- **Set**: Unordered collection of unique values. Elements must be `Hashable`.
  - Swift basic types (`String`, `Int`, `Double`, `Bool`) and enum cases without associated values are `Hashable` by default.
  - Custom types: conform to `Hashable`.
  - Common operations:
    ```swift
    var favoriteGenres: Set = ["Rock", "Classical", "Hip hop"]
    favoriteGenres.count          // 3
    favoriteGenres.isEmpty        // false
    favoriteGenres.insert("Jazz")
    favoriteGenres.remove("Rock") // Optional("Rock")
    favoriteGenres.contains("Funk") // false
    for genre in favoriteGenres { print(genre) }
    ```
  - Set algebra:
    - `intersection(_:)` — intersection
    - `symmetricDifference(_:)` — symmetric difference
    - `union(_:)` — union
    - `subtracting(_:)` — difference
    ```swift
    let oddDigits: Set = [1, 3, 5, 7, 9]
    let evenDigits: Set = [0, 2, 4, 6, 8]
    let primes: Set = [2, 3, 5, 7]
    oddDigits.union(evenDigits).sorted()                    // [0,1,2,3,4,5,6,7,8,9]
    oddDigits.intersection(evenDigits).sorted()             // []
    oddDigits.subtracting(primes).sorted()                  // [1, 9]
    oddDigits.symmetricDifference(primes).sorted()          // [1, 2, 9]
    ```
  - Set membership:
    ```swift
    let houseAnimals: Set = ["🐶", "🐱"]
    let farmAnimals: Set = ["🐮", "🐔", "🐑", "🐶", "🐱"]
    let cityAnimals: Set = ["🐦", "🐭"]
    houseAnimals.isSubset(of: farmAnimals)     // true
    farmAnimals.isSuperset(of: houseAnimals)   // true
    farmAnimals.isDisjoint(with: cityAnimals)  // true
    ```
- **Dictionary**: Unordered key-value pairs. Keys must be `Hashable`.

All three are generic collections. Bridged to Foundation's `NSArray`, `NSSet`, `NSDictionary`.

## Control Flow

- **`guard`**: Early exit. If condition is false, the `else` block must exit the scope.
- **`defer`**: Executes when the current scope ends, regardless of how control leaves (return, break, throw, or natural end).
  ```swift
  var score = 1
  if score < 10 {
      defer { print(score) }
      score += 5
  }
  // Prints "6"
  ```
  - Multiple `defer` blocks execute in reverse order (LIFO).
  - Guaranteed execution on `return`, `break`, `throw`.
  - **Not** executed on crashes (e.g., `fatalError`, bad memory access).
  - Use case: paired operations — unlock, release memory, close file handles, end DB transactions.

- **Control Transfer Statements** (5 total):
  - `continue` — skip current loop iteration
  - `break` — exit entire control flow
  - `fallthrough` — continue to next `switch` case
  - `return` — return from function
  - `throw` — throw an error

- **Pattern Matching** in `for` and `if`:
  ```swift
  let points = [(10, 0), (30, -30), (-20, 0)]
  for case (let x, 0) in points {
      print("Point on x-axis at \(x)")
  }
  for case let (x, y) in points where x == y || x == -y {
      print("(\(x), \(y)) on diagonal")
  }
  ```

- **`where` clause**: Add conditions to `case` branches.
  ```swift
  switch (1, -1) {
  case let (x, y) where x == y:  print("on x == y")
  case let (x, y) where x == -y: print("on x == -y")
  case let (x, y):                print("arbitrary point")
  }
  ```

## Functions

Skim the documentation for basics.

### Key Points

- **Argument labels vs parameter names**: Each parameter has an external label and internal name. Default: label = name.
  ```swift
  func greet(person: String, from hometown: String) -> String { ... }
  greet(person: "Bill", from: "Cupertino")
  ```
- **Omit label**: Use `_`.
  ```swift
  func someFunction(_ first: Int, second: Int) { ... }
  someFunction(1, second: 2)
  ```
- **Default values**: Place after parameters without defaults.
  ```swift
  func f(a: Int, b: Int = 12) { ... }
  ```
- **Variadic parameters**: `Double...` accepts zero or more values.
- **In-Out parameters**: `inout` + `&` at call site. Modifies the original variable.
  ```swift
  func swapTwoInts(_ a: inout Int, _ b: inout Int) { ... }
  swapTwoInts(&someInt, &anotherInt)
  ```

### Function Types

```swift
func addTwoInts(_ a: Int, _ b: Int) -> Int { ... }
var mathFunction: (Int, Int) -> Int = addTwoInts
// As parameter:
func printMathResult(_ mathFunction: (Int, Int) -> Int, _ a: Int, _ b: Int) { ... }
// As return type:
func chooseStepFunction(backward: Bool) -> (Int) -> Int { ... }
```

### Nested Functions
```swift
func chooseStepFunction(backward: Bool) -> (Int) -> Int {
    func stepForward(input: Int) -> Int { input + 1 }
    func stepBackward(input: Int) -> Int { input - 1 }
    return backward ? stepBackward : stepForward
}
```

## Closures

A **closure** captures and stores references to constants/variables from its surrounding context.

Three forms:
- **Global functions** — named, capture nothing
- **Nested functions** — named, capture from enclosing scope
- **Closure expressions** — anonymous, lightweight syntax, capture from context

### Closure Expression Syntax
```swift
{ (parameters) -> ReturnType in statements }
```

Shorthand forms (using `sorted` as example):
```swift
reversedNames = names.sorted(by: { s1, s2 in return s1 > s2 })  // inferred types
reversedNames = names.sorted(by: { s1, s2 in s1 > s2 })          // implicit return
reversedNames = names.sorted(by: { $0 > $1 })                    // shorthand args
reversedNames = names.sorted { $0 > $1 }                         // trailing closure
reversedNames = names.sorted(by: >)                              // operator method
```

### Trailing Closures
When a closure is the last argument, write it outside the parentheses. If it's the only argument, omit `()`.
```swift
someFunctionThatTakesAClosure() { ... }
someFunctionThatTakesAClosure { ... }  // only argument → omit ()
```

Common higher-order functions:
```swift
[1, 2, 3].map { "\($0)" }                    // ["1", "2", "3"]
["1", "2", "3", "a"].compactMap { Int($0) }  // [1, 2, 3] — filters nil
[1, 2, 3].flatMap { Array(repeating: $0, count: $0) } // [1, 2, 2, 3, 3, 3]
[-1, 1, 2].filter { $0 < 0 }                 // [-1]
[1, 2, 3].reduce(0, +)                       // 6
```

Multiple trailing closures:
```swift
loadPicture(from: server) { picture in
    someView.currentPicture = picture
} onFailure: {
    print("Download failed.")
}
```

### Capturing Values
Closures capture by reference. Swift handles memory management for captured variables.
```swift
func makeIncrementer(forIncrement amount: Int) -> () -> Int {
    var runningTotal = 0
    func incrementer() -> Int {
        runningTotal += amount
        return runningTotal
    }
    return incrementer
}
let incByTen = makeIncrementer(forIncrement: 10)
incByTen() // 10
incByTen() // 20
```

**Warning**: If a closure assigned to a class property captures `self`, it creates a strong reference cycle. Use **capture lists** (`[weak self]`, `[unowned self]`) to break it.

### Closures Are Reference Types
Assigning a closure to a variable/constant creates a reference. Two variables pointing to the same closure share state.

### Escaping Closures (`@escaping`)
A closure that outlives the function it's passed to (e.g., stored for async callback). Must be marked `@escaping`.
```swift
var completionHandlers: [() -> Void] = []
func someFunctionWithEscapingClosure(completionHandler: @escaping () -> Void) {
    completionHandlers.append(completionHandler)
}
```
- Referencing `self` in an escaping closure risks a strong reference cycle.
- Escaping closures cannot capture a mutable reference to `self` in structs/enums (value types don't allow shared mutability).
  ```swift
  struct SomeStruct {
      var x = 10
      mutating func doSomething() {
          someFunctionWithNonescapingClosure { x = 200 }  // OK
          someFunctionWithEscapingClosure { x = 100 }     // Error
      }
  }
  ```

### Autoclosures (`@autoclosure`)
Wraps an expression in a closure automatically. Enables **lazy evaluation** — the expression isn't evaluated until the closure is called.
```swift
func assert(_ condition: @autoclosure () -> Bool,
            _ message: @autoclosure () -> String = String(),
            file: StaticString = #file, line: UInt = #line)
```
Key use: `&&`, `||` operators use autoclosures for short-circuit evaluation.

## Enumerations, Structures and Classes, Methods, Subscripts, Inheritance, Deinitialization, Optional Chaining
Skim or skip.

## Initialization

Assign initial values to stored properties and perform one-time setup.

**Note**: Setting a default value or assigning in an initializer bypasses property observers.

### Parameter Names and Argument Labels
Same rules as functions. Default: label = parameter name. Use `_` to omit.
```swift
struct Celsius {
    var temperatureInCelsius: Double
    init(_ celsius: Double) { temperatureInCelsius = celsius }
}
let temp = Celsius(37.0)
```

### Default Initializers
If all properties have defaults and no custom initializers exist, Swift provides a default (designated) initializer.

### Memberwise Initializers (Structs)
Structs without custom initializers get an auto-generated memberwise initializer. Properties with defaults can be omitted at the call site.
```swift
struct Size { var width = 0.0, height = 0.0 }
let s = Size(width: 2.0, height: 2.0)
let s2 = Size(height: 2.0) // width defaults to 0.0
```
Tip: Write custom initializers in an extension to keep the memberwise initializer.

### Class Inheritance and Initialization

| Type | Keyword | Delegation Rule | Purpose |
|---|---|---|---|
| Designated | None | Must delegate **up** (call super's designated init) | Full initialization |
| Convenience | `convenience` | Must delegate **across** (call another init in same class) | Shortcut / defaults |

**Initializer Delegation Rules**:
1. Designated initializers must call a parent designated initializer.
2. Convenience initializers must call another initializer from the same class.
3. A subclass must initialize its own properties **before** calling `super.init()`.

### Two-Phase Initialization

- **Phase 1**: Each stored property is assigned an initial value, working up the class hierarchy. Until Phase 1 completes, `self` cannot be accessed.
- **Phase 2**: Working down the hierarchy, each initializer may customize properties and call instance methods.

```swift
class Person {
    var name: String
    var age: Int
    init(name: String, age: Int) {
        self.name = name   // Phase 1
        self.age = age     // Phase 1
        self.greet()       // Phase 2 — now safe
    }
    convenience init() {
        self.init(name: "Tom", age: 20)  // must delegate first
        print(self.name)                  // Phase 2
    }
    func greet() { print("Hello, I'm \(name)") }
}
```

### Initializer Inheritance and Overriding

Swift subclasses **don't** inherit parent initializers by default.

**Automatic initializer inheritance** (when subclass provides defaults for all new properties):
- **Rule 1**: If subclass defines no designated initializers → inherits all parent designated initializers.
- **Rule 2**: If subclass implements all parent designated initializers → inherits all parent convenience initializers.

Overriding a parent designated initializer requires `override`. Overriding a parent convenience initializer does **not** (since subclasses can't call parent convenience initializers directly).

If a subclass has no custom Phase 2 logic and the parent has a zero-argument designated init, `super.init()` is implicitly called.

### Failable Initializers (`init?` / `init!`)
Return `nil` on failure. The result is an optional type.
```swift
struct Animal {
    let species: String
    init?(species: String) {
        if species.isEmpty { return nil }
        self.species = species
    }
}
```
Enums with raw values get `init?(rawValue:)` automatically.

You can override a failable initializer with a nonfailable one, but **not** vice versa.

### Required Initializers (`required`)
All subclasses must implement (or inherit). Subclass implementations use `required` (not `override`).
```swift
class Animal {
    required init() { }
}
class Dog: Animal {
    required init() { }
}
```

### Initializer Summary Table

| Type | Keyword | Delegation | Use Case |
|---|---|---|---|
| Designated | None | Up to parent | Primary init logic |
| Convenience | `convenience` | Across in same class | Defaults / shortcuts |
| Required | `required` | Per rules | Force subclass conformance |
| Failable | `init?` / `init!` | Per rules | May return nil |
| Default | None (auto) | N/A | Auto-generated when conditions met |

## Properties

### Property Wrappers

A mechanism for **reusing property access logic** — syntactic sugar for shared `get`/`set` behavior.

- Define with `@propertyWrapper` + `wrappedValue` property.
- Optionally define `projectedValue` (accessed via `$` prefix).
- Cannot be used on computed properties, global variables, or constants.
- The compiler synthesizes a private `_propertyName` backing instance.

```swift
@propertyWrapper
struct TwelveOrLess {
    private var number = 0
    var wrappedValue: Int {
        get { number }
        set { number = min(newValue, 12) }
    }
}

struct SmallRectangle {
    @TwelveOrLess var height: Int
    @TwelveOrLess var width: Int
}
// Compiler generates: private var _height = TwelveOrLess(), etc.
```

**Setting initial values via init**:
```swift
@propertyWrapper
struct SmallNumber {
    private var maximum: Int
    private var number: Int
    var wrappedValue: Int {
        get { number }
        set { number = min(newValue, maximum) }
    }
    init() { maximum = 12; number = 0 }
    init(wrappedValue: Int) { maximum = 12; number = min(wrappedValue, maximum) }
    init(wrappedValue: Int, maximum: Int) { self.maximum = maximum; number = min(wrappedValue, maximum) }
}

@SmallNumber var x: Int              // uses init()
@SmallNumber var y: Int = 1          // uses init(wrappedValue:)
@SmallNumber(wrappedValue: 2, maximum: 5) var z: Int  // uses init(wrappedValue:maximum:)
@SmallNumber(maximum: 9) var w: Int = 2               // uses init(wrappedValue:maximum:)
```

**Projected Value** (`$` prefix):
```swift
@propertyWrapper
struct SmallNumber {
    private var number: Int
    private(set) var projectedValue: Bool
    var wrappedValue: Int {
        get { number }
        set { if newValue > 12 { number = 12; projectedValue = true }
              else { number = newValue; projectedValue = false } }
    }
    init() { number = 0; projectedValue = false }
}

struct SomeStructure { @SmallNumber var someNumber: Int }
var s = SomeStructure()
s.someNumber = 4;   print(s.$someNumber)  // false
s.someNumber = 55;  print(s.$someNumber)  // true
```

**Real-world usage**: `@State`, `@Published`, `@AppStorage` in SwiftUI/Combine.

## Error Handling
See: [Swift Error Handling Notes](https://github.com/HaiTeng-Wang/Book/blob/master/iOS/Swift%20Error%20Handling%20%E7%AC%94%E8%AE%B0.md)

## Concurrency

Quick overview: [Guided Tour — Concurrency](https://doc.swiftgg.team/documentation/the-swift-programming-language/guidedtour#%E5%B9%B6%E5%8F%91%E6%80%A7)

SwiftUI `.task` modifier.

### Actor
Isolated concurrent type — ensures only one task accesses mutable state at a time.

- `@MainActor` — marks code that must run on the main thread.
- `@GlobalActor` — custom global actor.

### Sendable Types
Types safe to share across concurrency domains. Conform to `Sendable` protocol (no code requirements, only semantic).

Three ways a class can be Sendable:
1. Value type with only Sendable stored properties.
2. Immutable type with only Sendable read-only properties.
3. Type with serialized access to mutable state (e.g., `@MainActor`, queue-protected).

```swift
struct TemperatureReading { var measurement: Int } // implicitly Sendable
```

## Macros
TODO: Merge with home notes.

## Type Casting, Nested Types, Extensions
Skim or skip.

## Protocols
Skim the documentation.

## Generics
Skim the documentation.

## Opaque Types and Boxed Protocol Types

| | `some` (Opaque) | `any` (Boxed Protocol) |
|---|---|---|
| Dispatch | Static | Dynamic |
| Return type | Must be one concrete type | Can be different concrete types |
| Use case | Hide implementation detail, preserve performance | Heterogeneous collections, flexible returns |

```swift
// Opaque — always returns the same concrete type
func getPet() -> some Animal { return Dog() }

// Boxed protocol — can return different types
func getPet(by color: Color) -> any Animal {
    if color == .red { return Dog() } else { return Cat() }
}
```

### Opaque Parameters
`some` in parameter position is shorthand for generics:
```swift
func drawTwice(_ shape: some Shape) -> String { ... }
// Equivalent to: func drawTwice<SomeShape: Shape>(_ shape: SomeShape) -> String { ... }
```
Each `some` parameter is an independent generic type.

## Automatic Reference Counting (ARC)

ARC tracks and manages memory for **class instances only**. Structs and enums are value types — not reference-counted.

### Weak vs Unowned References

Both break strong reference cycles.

| | `weak` | `unowned` |
|---|---|---|
| Type | Optional (`?`) | Non-optional (implicitly unwrapped) |
| When nil? | Becomes `nil` if deallocated | Crashes if accessed after deallocation |
| Use when | Other instance may have shorter lifecycle | Other instance has same or longer lifecycle |

**Common patterns**:
- `weak`: delegate, escaping closures, tenant→apartment
- `unowned`: closure capturing `self` (same lifecycle), credit card→customer

```swift
// weak — apartment may have no tenant
class Apartment {
    weak var tenant: Person?
}

// unowned — credit card always has an owner
class CreditCard {
    unowned let customer: Customer
}
```

### Other Memory Leak Sources
- **Timer**: RunLoop retains repeating timers. Call `invalidate()`.
- **Notifications**: Block-based observers are retained by the system. Remove manually.
- **Core Foundation objects**: Manual release required.
- **UIWebView**: Deprecated, known memory issues.

### Memory Leak Detection
1. Breakpoint on `deinit`
2. Xcode Debug Navigator — check instance count
3. Instruments Leaks
4. Static analysis
5. Third-party libraries (swizzle VC pop + delayed weak check)

## Memory Safety

Access conflicts occur when:
- At least one access is a write
- They access the same memory
- Their durations overlap

Common cases:
1. **In-Out parameter conflicts**: passing the same variable to multiple `inout` params, or reading a variable while it's an `inout` param.
2. **Struct property conflicts**: overlapping write access to properties of a global struct variable. (Safe for local variables — compiler can prove non-overlap.)
3. **Multithreading**: data races (not covered in Swift docs but important).

## Access Control

Four key points:

1. **Access level hierarchy**: `open` → `public` → `package` → `internal` (default) → `fileprivate` → `private`
   - `open`: only for classes/class members — allows subclassing/overriding outside the module.

2. **Principle**: An entity cannot have a higher access level than its dependencies.
   - A `public` variable cannot have an `internal` type.
   - A function's access level ≤ its parameter/return types.
   - A tuple's access level = most restrictive element.
   - A subclass's access level ≤ its parent class.
   - A `public` protocol cannot inherit from an `internal` protocol.

3. **Setter access**: Use `private(set)`, `fileprivate(set)`, `internal(set)`, or `package(set)` to make a setter more restrictive than its getter.

4. **Default member access for `public` types**: `internal`, not `public`. Must explicitly mark as `public`.
   - Default initializer of a `public` type is `internal`.
   - Required initializer access level cannot be lower than `internal` (for `public` classes).
   - Struct memberwise initializer: if any stored property is `private`/`fileprivate`, the memberwise init matches that level.

## Advanced Operators
Omitted.

## Attributes

### resultBuilder
TODO — e.g., SwiftUI's `@ViewBuilder`.

---

# Extensions

## `?` vs `!` in Swift

| | `?` (Optional) | `!` (Implicitly Unwrapped Optional) |
|---|---|---|
| Declaration | Safe optional | Unsafe optional (auto-unwrap) |
| Access | Requires unwrapping | Direct access; crashes if nil |
| Default value | `nil` | `nil` |

**Safe unwrapping**:
```swift
// if let / guard let
if let name = optionalName { print(name) }
// Nil-coalescing
let display = name ?? "Default"
// Optional chaining
let count = name?.count  // nil if name is nil
```

**Force unwrap** (dangerous):
```swift
print(name!)  // crashes if nil
```

Other `?`/`!` scenarios:
- `init?` — failable initializer
- `as?` / `as!` — safe / forced type cast
- Dictionary subscript returns `Optional`
- `try?` / `try!` — safe / forced error handling
- `@IBOutlet` uses `!` by default (guaranteed after `viewDidLoad`)

Safe array subscript extension:
```swift
extension Array {
    subscript(safe index: Int) -> Element? {
        guard index >= 0 && index < count else { return nil }
        return self[index]
    }
}
```

## Swift vs Objective-C

| | Swift | Objective-C |
|---|---|---|
| Type safety | Static, strong typing | Dynamic, weak typing |
| nil handling | `Optional` enforced by compiler | Messaging nil is OK; undefined behavior |
| Value types | Structs, enums, COW | Mostly reference types |
| Syntax | Modern — no header files, no semicolons, no brackets | C-based, verbose |
| Flow control | `for-in`, `guard`, `defer`, pattern matching `switch` | Traditional `for`, `while` |
| Memory | ARC (class instances) | ARC (class instances) + manual Core Foundation |
| Runtime | Limited reflection | Full dynamic runtime (`objc_msgSend`, swizzling, KVC) |

**Swift milestones**:
- **2019 (Swift 5.0, iOS 13+)**: ABI stability. Combine framework. SwiftUI.
- **2021 (Swift 5.5, iOS 15+)**: Concurrency (`async/await`, `Actor`, `@MainActor`).
- **2023 (Swift 5.9, iOS 17+)**: Macros. `@Observable` replaces `ObservableObject`/`@Published`.
- **2024**: Swift Testing framework (`@Test`, `@Suite`).

## Class vs Struct

| | Class | Struct |
|---|---|---|
| Type | Reference (heap, ARC) | Value (stack, COW) |
| Inheritance | Yes | No |
| `let` instance | `var` properties still mutable | All properties immutable |
| `mutating` | N/A | Required for methods that modify self |
| Identity | `===` (reference equality) | `Equatable` (value equality) |
| Init | Designated + convenience | Auto memberwise init |
| Deinit | Yes | No |
| Memory leaks | Possible (cycles) | No (value type) |

`mutating` keyword: required for struct methods that modify properties. Cannot be called on `let` instances.

`nonmutating` keyword: marks a setter that doesn't modify the struct's storage (e.g., writing to `UserDefaults`).

## View Controller Lifecycle

**Push**: v2 `init` → `viewDidLoad` → v1 `viewWillDisappear` → v2 `viewWillAppear` → `viewWillLayoutSubviews` → `viewDidLayoutSubviews` → v1 `viewDidDisappear` → v2 `viewDidAppear`

**Pop**: v2 `viewWillDisappear` → v1 `viewWillAppear` → v2 `viewDidDisappear` → v1 `viewDidAppear` → v2 `dealloc`

**Modal**: v1 only calls `viewWillLayoutSubviews` / `viewDidLayoutSubviews` (no appear/disappear). v2 follows same lifecycle as push.

```objc
- (instancetype)init
- (instancetype)initWithCoder:(NSCoder *)coder
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
- (void)awakeFromNib
- (void)loadView
- (void)viewDidLoad
- (void)viewWillAppear:(BOOL)animated
- (void)viewWillLayoutSubviews
- (void)viewDidLayoutSubviews
- (void)viewDidAppear:(BOOL)animated
- (void)viewWillDisappear:(BOOL)animated
- (void)viewDidDisappear:(BOOL)animated
- (void)dealloc
```

### Design Patterns
TODO: Router, Framework, Module design.

### Combine
TODO.