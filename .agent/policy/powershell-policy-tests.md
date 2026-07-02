# PowerShell Policy Test Cases

This document outlines the test scenarios agents must validate against when generating or reviewing PowerShell code.

## 1. Security Validation
- [ ] **Secret Detection**: Verify no hardcoded passwords, API keys, or tokens exist in the script.
- [ ] **Injection Prevention**: Ensure `Invoke-Expression` is not used with variable input.
- [ ] **Path Traversal**: Validate that file paths are sanitized and resolved before use.
- [ ] **Execution Policy**: Scripts should not attempt to bypass execution policy globally; rely on signing or scoped bypasses.

## 2. Syntax & Best Practices
- [ ] **Verb-Noun Convention**: All function names must follow approved PowerShell verbs (`Get-`, `Set-`, `Invoke-`, etc.).
- [ ] **Comment-Based Help**: Every public function must have a `<# ... #>` help block.
- [ ] **Strict Mode**: Evaluate if `Set-StrictMode` is appropriate for the context.
- [ ] **Variable Scoping**: Ensure variables are not accidentally global unless intended.

## 3. Error Handling Robustness
- [ ] **Try/Catch Coverage**: Critical operations (IO, Network, Registry) are wrapped in `try/catch`.
- [ ] **ErrorAction**: `-ErrorAction Stop` is used where failures should halt execution or trigger catches.
- [ ] **Meaningful Messages**: Error messages provide actionable context, not just raw exception strings.

## 4. Pipeline Efficiency
- [ ] **Input Acceptance**: Functions intended for chaining accept `ValueFromPipeline`.
- [ ] **Output Objects**: Functions output objects, not formatted strings, to allow further filtering.
- [ ] **Streaming**: Large datasets are processed in `process` blocks, not loaded entirely into memory first.

## 5. Parameter Validation
- [ ] **Mandatory Checks**: Critical parameters are marked `[Parameter(Mandatory = $true)]`.
- [ ] **Type Safety**: Parameters have explicit types (e.g., `[string]`, `[int]`, `[PSCredential]`).
- [ ] **ValidateSet/Pattern**: Use `[ValidateSet()]` or `[ValidatePattern()]` where input is restricted.

## 6. Testing Coverage (Pester)
- [ ] **Happy Path**: Tests exist for standard successful execution.
- [ ] **Edge Cases**: Tests cover empty inputs, null values, and boundary conditions.
- [ ] **Mocking**: External calls (API, File System) are mocked in unit tests.
- [ ] **Assertion Accuracy**: Tests assert specific properties, not just "not null".

## 7. Cross-Platform Compatibility
- [ ] **Cmdlet Availability**: Used cmdlets exist on Non-Windows (avoid WMI/CIM where possible, prefer `Get-Process` over `Get-CimInstance` if simple).
- [ ] **Path Separators**: Use `Join-Path` instead of hardcoding `\` or `/`.
- [ ] **Case Sensitivity**: Logic accounts for case-sensitive file systems on Linux/macOS.

## 8. Performance
- [ ] **Loop Optimization**: Avoid heavy operations inside tight loops.
- [ ] **Collection Management**: Use typed lists `[System.Collections.Generic.List[T]]` for large dynamic collections instead of standard arrays `@()`.
- [ ] **Disposable Objects**: Ensure objects implementing `IDisposable` are properly disposed.