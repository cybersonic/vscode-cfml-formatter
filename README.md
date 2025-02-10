# CFML Formatter

CFML formatter is a Visual Studio Code extension that provides formatting for CFML files using [Lucee Server](https://www.lucee.org/) and [CFFormat]((https://github.com/jcberquist/commandbox-cfformat)

Under the hood it uses a Lucee Language Server to provide the formatting capabilities. 

## Features
- Format CFML files using cfformat right in the editor
![Right click format](assets/RightClickFormat.gif "Right click format")
- Triggered on Save or via VSCode's `Format Document` command (`Shift` + `Alt` + `F`)
![Format on Save](assets/FormatOnSave.gif "Format on Save")
## Development

### Requirements
- Java 11 to run the LSP server
- Ant and Maven
- Node.js and npm
- VS Code and vscx

### Building and Packaging
- Run `npm run vscode:pacakge`
- Run `ant` to build the project, it will create a lucee war file and a jar file for the language server, 
