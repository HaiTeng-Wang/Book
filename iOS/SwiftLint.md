# SwiftLint

大概需要20-40分钟阅读下[文档](https://github.com/realm/SwiftLint/blob/master/README_CN.md)了解下如何安装、配置、运行机制，以及[规则](https://realm.github.io/SwiftLint/rule-directory.html)。

项目中的.swiftlint.yml文件配置如下

```
disabled_rules: # rule identifiers to exclude from running
  - colon
  - comma
  - control_statement
  - line_length
  - trailing_whitespace
  - empty_count
  - shorthand_operator
  - file_length
  - cyclomatic_complexity
  - function_body_length
  - large_tuple
opt_in_rules: # some rules are only opt-in
  # Find all the available rules by running:
  # swiftlint rules
included: # paths to include during linting. `--path` is ignored if present.
    - SBIUSStock
excluded: # paths to ignore during linting. Takes precedence over `included`.
    - SBIUSStock/Service/Apollo/API
    - SBIUSStock/Service/Apollo/Network
    - Carthage
    - Pods
    - Sources/ExcludedFolder
    - Sources/ExcludedFile.swift
    - Sources/*/ExcludedFile.swift # Exclude files with a wildcard
analyzer_rules: # Rules run by `swiftlint analyze` (experimental)
  - explicit_self

# configurable rules can be customized from this configuration file
# binary rules can set their severity level
force_cast: warning # implicitly
force_try:
  severity: warning # explicitly
# rules that have both warning and error levels, can set just the warning level
# implicitly
line_length: 110
# they can set both implicitly with an array
type_body_length:
  - 300 # warning
  - 400 # error
# or they can set both explicitly
file_length:
  warning: 500
  error: 1200
# naming rules can set warnings/errors for min_length and max_length
# additionally they can set excluded names
type_name:
  min_length: 2 # only warning
  max_length: # warning and error
    warning: 40
    error: 50
  excluded: iPhone # excluded via string
identifier_name:
  min_length: 1
  excluded: # excluded via string array
    - i
    - j
    - x
    - y
    - z
    - id
    - URL
    - GlobalAPIKey
reporter: "xcode" # reporter type (xcode, json, csv, checkstyle, junit, html, emoji, sonarqube, markdown)

```

在coding的过程中当收到xcode编译器来自swiftlint的警告或error，如果不明白为什么可以去[规则](https://realm.github.io/SwiftLint/rule-directory.html)中搜索下，或者"（如果必要或允许）"的情况下可以[在代码中关闭某个规则](https://github.com/realm/SwiftLint/blob/master/README_CN.md#%E5%9C%A8%E4%BB%A3%E7%A0%81%E4%B8%AD%E5%85%B3%E9%97%AD%E6%9F%90%E4%B8%AA%E8%A7%84%E5%88%99)。