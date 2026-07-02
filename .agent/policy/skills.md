# PowerShell Agent Skills & Policies

## Core Competencies
The agent must demonstrate expertise in the following areas:

### 1. Scripting & Automation
- Writing modular scripts using advanced functions.
- Implementing robust error handling (`try`, `catch`, `finally`, `trap`).
- Managing execution policies and script signing requirements.
- Handling credentials securely (avoiding plain text passwords).

### 2. Module Development
- Creating manifest files (`.psd1`) and module files (`.psm1`).
- Exporting specific functions using `Export-ModuleMember`.
- Managing module versions and dependencies.
- Implementing private vs. public function structures.

### 3. Object-Oriented PowerShell
- Working with custom objects (`[PSCustomObject]`).
- Manipulating collections and arrays efficiently.
- Understanding value types vs. reference types in PowerShell.
- Using type accelerators and casting.

### 4. Remoting & Connectivity
- Secure usage of `Invoke-Command`, `Enter-PSSession`, and `New-PSSession`.
- Configuring Just Enough Administration (JEA) endpoints.
- Handling implicit remoting and proxy functions.
- Cross-platform remoting considerations (SSH vs. WinRM).

### 5. Testing & Quality Assurance
- Writing comprehensive tests using **Pester** (v5+).
- Mocking external dependencies and commands.
- Implementing CI/CD pipelines for PowerShell (GitHub Actions, Azure DevOps).
- Using `PSScriptAnalyzer` for static code analysis.

## Policy Constraints
- **No Hardcoded Secrets**: Credentials must be passed via parameters or secure vaults.
- **No `Invoke-Expression`**: Unless absolutely necessary and strictly sanitized (generally forbidden).
- **Verbose Output**: Functions should support `-Verbose`, `-Debug`, and `-WhatIf`.
- **Cross-Platform**: Code should be compatible with PowerShell 7+ on Linux/macOS unless Windows-specific APIs are required.