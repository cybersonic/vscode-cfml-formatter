import * as path from "path";
import { workspace, ExtensionContext, window } from "vscode";
import * as net from "node:net";
import * as vscode from 'vscode';
import { startServer } from "./languageServer";
import { detect } from 'detect-port';
import { isExecutableFile } from "./utils/fileUtils";


// 
import * as child_process from "child_process";
import { isOSWindows } from "./utils/osUtils";
import { LOG, Logger } from "./utils/logger";
import {
  LanguageClient,
  LanguageClientOptions,
  ServerOptions,
  ErrorAction,
  CloseAction,
  StreamInfo,
} from "vscode-languageclient/node";
import { Status, StatusBarEntry } from './utils/status';


const label = "CFML Formatter";
let lspPort: number = 2089;
let serverPort: number = 4000;
const startLucee: boolean = true; //Set to false if you want to use your own server
// const socket_timeout = 5000; //Not used, this would be a timeout for the startServer function
const outputChannel = window.createOutputChannel(label);
let lspjar: String;
const lspfilename = "lucee_lsp-1.0-all.jar";
const defaultJavaPath = "/usr/bin/java";

let luceeServer;


function getRandomNumber(min: number, max: number): number {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}


function getSettings() {
  const config = vscode.workspace.getConfiguration("cfml-formatter");
  const javaPath: string = config.get("javaPath");
  const startLucee: boolean = config.get("startLuceeServer");
  const lspPort: number = config.get("lspPort");
  const serverPort: number = config.get("serverPort");


  return {
    javaPath,
    startLucee,
    lspPort,
    serverPort
  }
}

export async function activate(context: ExtensionContext) {

  const settings = getSettings();
  // Need to find the location of java, JAVA_HOME
  let javaPath: string = settings.javaPath || defaultJavaPath || process.env.JAVA_HOME;

  if (!isExecutableFile(javaPath)) {
    const message = `[${label}] ${javaPath} but it is not executable`;
    LOG.error(message)
    vscode.window.showErrorMessage(message);
    return;
  }
  // vscode.window.showInformationMessage(`[${label}] Using Java at ${javaPath}`);
  // Get it from the settings, check that is true, if not try JAVA_HOME 


  // Check that the binary for java is available
  // const javaPath: string = settings.javaPath || defaultJavaPath;

  // Check that the binary for java is available
  lspjar = path.join(context.extensionPath, 'resources', lspfilename);

  const startLucee = settings.startLucee;
  let lspPort = settings.lspPort || getRandomNumber(2000, 3000);
  let serverPort = settings.serverPort || getRandomNumber(4000, 5000);

  if (startLucee) {
    lspPort = getRandomNumber(2000, 3000);
    serverPort = getRandomNumber(4000, 5000);
    lspPort = await detect(lspPort);
    serverPort = await detect(serverPort);
  }
  // let serverOptions: ServerOptions;

  LOG.info("LSP Extension Port {}", lspPort);
  LOG.info("LSP Extension Web Server Port {}", serverPort);

  if (startLucee) {

    LOG.info("Starting Lucee LSP Server");
    // window.withProgress({
    //   location: vscode.ProgressLocation.Notification,
    //   title: "Starting Lucee LSP Server",
    //   cancellable: false
    // }, async (progress, token) => {

    // }
    // );

    // startServer(javaPath, [`-Dlucee.lsp.port=${lspPort}`, `-Dlucee.server.port=${serverPort}`, `-Dlucee.server.wardir=/tmp`, "-jar", lspjar], outputChannel);

    luceeServer = await startServer(javaPath, [`-Dlucee.lsp.port=${lspPort}`, `-Dlucee.server.port=${serverPort}`, `-Dlucee.server.wardir=/tmp`, "-jar", lspjar], outputChannel);

    LOG.info("Started Lucee LSP Server");
  }
  else {
    LOG.info("Not Starting Lucee LSP Server, using existing server on port {}", lspPort);
  }

  LOG.info("Connecting to Lucee LSP Server on port: {}", lspPort);
  const serverOptions: ServerOptions = async () => {
    return new Promise<StreamInfo>((resolve, reject) => {
      const socket = net.connect({ port: lspPort });

      socket.on("connect", () => {
        LOG.info("Connected to server");
        resolve({
          // process: luceeServer,
          reader: socket,
          writer: socket,
        });
      });

      // Error handling
      socket.on("error", (err) => {
        LOG.error(`Server error: ${err.message}`);
        reject(err);
      });

      // Data event (optional logging/debugging)
      socket.on("data", (data) => {
        LOG.trace(`Server data: ${data}`);
      });

      // Cleanup (on close)
      socket.on("close", () => {
        LOG.info("Socket closed");
      });
    });
  };


  // Options to control the language client
  const clientOptions: LanguageClientOptions = {
    // Register the server for all documents by default
    documentSelector: [{ scheme: "file", language: "cfml" }],
    synchronize: {
      // Notify the server about file changes to varioius config files contained in the workspace
      fileEvents: [
        workspace.createFileSystemWatcher("**/.cfformat.json"),
        workspace.createFileSystemWatcher("**/.cfformat"),
        workspace.createFileSystemWatcher("**/.cfrules.json"),
        workspace.createFileSystemWatcher("**/.cfrules")
      ],
      configurationSection: "cfml-formatter"
    },
    errorHandler: {
      error: (error, message, count) => {
        console.error('Language server error:', error);
        return ErrorAction.Continue;
      },
      closed: () => {
        console.warn('Language server closed unexpectedly');
        return CloseAction.Restart;
      }
    }

  };

  // Create the language client and start the client.
  const client: LanguageClient = new LanguageClient(
    "cfml-formatter",
    "CFML Formatter",
    serverOptions,
    clientOptions,
    true
  );

  client.start();

  const openLanguageServerUrl = vscode.commands.registerCommand(
    "cfml-formatter.openServerURL",
    () => {
      const languageServerUrl = `http://localhost:${serverPort}/`; // Replace with your Language Server URL
      vscode.env.openExternal(vscode.Uri.parse(languageServerUrl));
      vscode.window.showInformationMessage(`Opened Language Server URL: ${languageServerUrl}`);
    }
  );


  // Start the client. This will also launch the server

}


function checkJavaVersion(javaPath: string): Promise<string> {
  const regex = /"([^"]+)"/;
  return new Promise((resolve, reject) => {
    const { spawn } = require('child_process');
    const child = spawn(javaPath, ['-version']);

    let versionOutput = '';

    child.stderr.on('data', (data) => {
      versionOutput += data.toString();
    });

    // Optional: capture stdout if needed (usually empty for -version)
    child.stdout.on('data', (data) => {
      versionOutput += data.toString();
    });

    child.on('close', (code) => {
      const firstLine = versionOutput.split("\n")[0];
      const match = regex.exec(firstLine);
      console.log(match[1]);
      resolve(match[1]);
    });

  });




  // return new Promise((resolve, reject) => {
  //   const javaVersion = child_process.spawn(javaPath, ["-version"]);
  //   let output = "";
  //   javaVersion.stdout.on("data", (data) => {
  //     output += data.toString();
  //     LOG.info("Java Version", output);
  //   });
  //   javaVersion.stderr.on("data", (data) => {
  //     output += data.toString();
  //   });
  //   javaVersion.on("close", (code) => {
  //     if (code === 0) {
  //       resolve(output);
  //     } else {
  //       reject(output);
  //     }
  //   });
  // });
}



async function withSpinningStatus(context: vscode.ExtensionContext, action: (status: Status) => Promise<void>): Promise<void> {
  const status = new StatusBarEntry(context, "$(sync~spin)");
  status.show();
  await action(status);
  status.dispose();
}



export function deactivate(): void {
  LOG.info("Deactivating CFML Formatter");
  if (luceeServer) {
    luceeServer.kill();
  }
}