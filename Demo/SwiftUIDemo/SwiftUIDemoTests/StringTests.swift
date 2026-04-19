//
//  StringTests.swift
//  CoreDataDemoTests
//
//  Created by Hunter on 2025/6/14.
//

import XCTest

// https://doc.swiftgg.team/documentation/the-swift-programming-language/stringsandcharacters
func stringPractice () {

    func testSort() {
        print("--------------------------------------testSort")
        // sorted vs sort
        let dic = [1: "a", 2: "b"].values.sorted()
        var varArray = [3, 2, 1]
        varArray.sort()
        print("sortedDic: \(dic) ---- sortArray\(varArray)")
        /*
         Split Vs Components(separateBy)
         https://medium.com/@MdNiks/split-vs-components-separateby-ca64e66c5a71
         https://developer.apple.com/documentation/foundation/nsstring/components(separatedby:)-238fy
         https://developer.apple.com/documentation/swift/collection/split(maxsplits:omittingemptysubsequences:whereseparator:)
         func split(
             separator: Self.Element,
             maxSplits: Int = Int.max,
             omittingEmptySubsequences: Bool = true
         ) -> [Self.SubSequence]

         let line = "BLANCHE:   I don't want realism. I want magic!"
         print(line.split(separator: " "))
         // Prints "["BLANCHE:", "I", "don\'t", "want", "realism.", "I", "want", "magic!"]"

         print(line.split(separator: " ", maxSplits: 1))
         // Prints "["BLANCHE:", "  I don\'t want realism. I want magic!"]"

         print(line.split(separator: " ", omittingEmptySubsequences: false))
         // Prints "["BLANCHE:", "", "", "I", "don\'t", "want", "realism.", "I", "want", "magic!"]"


         func components(separatedBy separator: String) -> [String]
         NSString *list = @"Karin, Carrie, David";
         NSArray *listItems = [list componentsSeparatedByString:@", "];
         produces the array @[@"Karin", @"Carrie", @"David"].

         If list begins with a comma and space—for example, @", Norman, Stanley, Fletcher"—the array has these contents: @[@"", @"Norman", @"Stanley", @"Fletcher"].
         If list has no separators—for example, @"Karin"—the array contains the string itself, in this case @[@"Karin"].
         */
    }

    func testConvert() {
        print("--------------------------------------testConvert")
        // convert, access index and remove
        var str = String(["1", "2", "3", "a", "2"])
        let removedString = str.remove(at: str.index(str.startIndex, offsetBy: 2))
        print(removedString)
        print(Array(str))
        print(String(Set(str))) // 可以互转去重，但无序。
        print("-----------------------\(Array("sdfdsffdsf"))")

        // map
        var mapResult = [1, 2, 3].map{"\($0)"}

        // compatMap filter nul
        mapResult.append("333fff")
        print(mapResult.compactMap{Int($0)})

        // flatMap In fact, s.flatMap(transform) is equivalent to Array(s.map(transform).joined()).
        let numbers = [1, 2, 3, 4]
        print(numbers.map { Array(repeating: $0, count: $0) })
        // [[1], [2, 2], [3, 3, 3], [4, 4, 4, 4]]
        print(numbers.flatMap { Array(repeating: $0, count: $0) })
        // [1, 2, 2, 3, 3, 3, 4, 4, 4, 4]
        print(numbers.flatMap{ String($0)}) // 此时和map一样
    }

    testSort()
    testConvert()
}

final class StringTests: XCTestCase {
    func testString() throws {
        func removeDuplication(for string: String) -> String {
            var set: Set<Character> = Set(), resultString: String = ""
            for char in string {
                if !set.contains(char) {
                    set.insert(char)
                    resultString.append(char)
                }
            }
            return resultString
        }

        func strStr(haystack: String, _ needle: String) -> Int {
            // 善用guard
            guard haystack.count != 0 && haystack.count >= needle.count else {
                return -1
            }

            for i in 0...haystack.count - needle.count {
                guard haystack[i] == needle[0] else {
                    continue
                }

                for j in 0 ..< needle.count {
                    guard haystack[i + j] == needle[j] else {
                        break
                    }
                    if j == needle.count - 1 {
                        return i
                    }
                }
            }

            return -1
        }

        func getCharasCount(_ string: String) -> [Character: Int] {
            var result = [Character: Int]()
            for chara in string {
                if result.keys.contains(chara), let value = result[chara] {
                    result[chara] = value + 1
                } else {
                    result[chara] = 1
                }
            }
            return result
        }

        /*
         Given an input string, reverse the string word by word.
         A word is defined as a sequence of non-space characters.
         The input string does not contain leading or trailing spaces and the words are always separated by a single space.
         For example,
         Given s = "the sky is blue",
         return "blue is sky the".
         Could you do it in-place without allocating extra space?
         */

        /*
        func reversWord(_ input: String) -> String {
            return input.split(separator: " ").reversed().joined(separator: " ")
        }
        */
        func reversWords(_ input: String?) -> String? {
            guard let input = input else { return nil }

            var charas = Array(input), start = 0
            _reverse(&charas, start, charas.count - 1)

            for i in 0 ..< charas.count {
                guard i == charas.count - 1 || charas[i + 1] == " " else { continue }
                _reverse(&charas, start, i)
                start = i + 2
            }
            return String(charas)
        }

        print("removeDuplication---:\(removeDuplication(for: "abcdddbf"))")

        print("firstNeedlForHayStack---:\(strStr(haystack: "hay stack", "sta"))")

        // 用字典和高阶函数计算字符串中每个字符的出现频率
        print("GetCharasCountWithDic---:\(Dictionary("hello".map { ($0, 1) }, uniquingKeysWith: +))")
        // 手动实现
        print("GetCharasCount---:\(getCharasCount("hello"))")
        // 也可以用reduce实现
        print("GetCharasCountWith reduce(into:)------:\("hello".reduce(into: [:]) { $0[$1, default: 0] += 1 })")

        print("revers the sky is blue: ------:\(reversWords("the sky is blue") ?? "nil")")
    }


    func testFirstUniqChar() {
        func firstUniqChar(_ s: String) -> Int {
            var dic = [Character: Int]()
            for char in s {
                dic[char, default: 0] += 1
            }
            for (index, char) in s.enumerated() {
                if dic[char] == 1 {
                    return index
                }
            }
            return -1
        }

        print("firstUniqChar：\(firstUniqChar("dsfsffee"))")
    }


    func testRemoveVowels() {
        func removeVowels(_ input: String) -> String {
            let vowels = ["a", "e", "i", "o", "u", "A", "E", "I", "O", "U"]
            return input.reduce(into: "") { partialResult, char in
                if !vowels.contains(String(char)) {
                    partialResult.append(char)
                }
            }
        }
        print(removeVowels("abcdeiOUfD"))
    }

    func testIsSymmetric() {
        func isSymmetric(_ str: String) -> Bool {
//          // solution 1
//            guard str.count > 2 else { return true }
//            let leftSplitPoint = (str.count % 2) == 0 ? (str.count / 2) - 1 : (str.count / 2)
//            let rightSplitPoint = str.count / 2
//            let leftStr = str[...str.index(str.startIndex, offsetBy: leftSplitPoint)]
//            let rightStr = str[str.index(str.startIndex, offsetBy: rightSplitPoint)...]
//            return leftStr == String(rightStr.reversed())

            // solution 2
            str.elementsEqual(str.reversed())

            // solution 3 使用双指针。左右指针分别指向str的两侧，while lef < right { if str[left] == str[right] return false right-- left++ } while循环检测完后，就可以return true了，说明是回文串。
        }
        print(isSymmetric("abba"))
        print(isSymmetric("aba"))
        print(isSymmetric("abbaa"))
    }

    func testIsPalindrome() {
        func isPalindrome(_ s: String) -> Bool {
            func isValid(_ char: Character) -> Bool {
                let lowercaseStr = "qwertyuiopasdfghjklzxcvbnm"
                let uppercaseStr = "QWERTYUIOPASDFGHJKLZXCVBNM"
                let num = "1234567890"
                return lowercaseStr.contains(char) || uppercaseStr.contains(char) || num.contains(char)
            }

            let validStr = s.reduce(into:"") {
                if isValid($1) {$0.append($1)}
            }

            return validStr.lowercased() == String(validStr.reversed()).lowercased()

        }
        print(isPalindrome("race a car"))
        print(isPalindrome("A man, a plan, a canal: Panama"))
    }

}

func _swap<T>(_ chars: inout [T], _ p: Int, _ q: Int) {
  (chars[p], chars[q]) = (chars[q], chars[p])
}

func _reverse<T>(_ chars: inout [T], _ start: Int, _ end: Int) {
    var start = start, end = end
    while start < end {
        _swap(&chars, start, end)
        start += 1
        end -= 1
    }
}

/*
 func reversString(_ originStr: String) -> String { // originStr.reversed()
     var arrayOutput = Array(originStr)
     for i in 0..<arrayOutput.count / 2 {
         _swap(&arrayOutput, i, arrayOutput.count - 1 - i)
     }
     return String(arrayOutput)
 }
 */

extension String {
  subscript(i: Int) -> Character {
    return self[index(startIndex, offsetBy: i)]
  }
}
