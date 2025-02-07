import * as path from "path";
import { workspace, ExtensionContext, window } from "vscode";
import * as net from "node:net";
import * as vscode from 'vscode';
import { startServer } from "./languageServer";
import { detect } from 'detect-port';


// 
import * as child_process from "child_process";
// import { isOSWindows } from "./utils/osUtils";
import { LOG } from "./utils/logger";
import {
  LanguageClient,
  LanguageClientOptions,
  ClientCapabilities,
  ServerOptions,
  TransportKind,
  SocketTransport,
  StreamInfo,
} from "vscode-languageclient/node";
import { Status, StatusBarEntry } from './utils/status';



let lspPort: number = 2089;
let serverPort: number = 4000;
const startLucee: boolean = false; //Set to false if you want to use your own server
const socket_timeout = 5000; //Not used, this would be a timeout for the startServer function
const outputChannel = window.createOutputChannel("CFML Formatter");
let lspjar: String;
const lspfilename = "lucee_lsp-1.0-all.jar";
const defaultJavaPath = "/usr/bin/java";

let luceeServer;


function getRandomNumber(min: number, max: number): number {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}


export async function activate(context: ExtensionContext) {

  // Get the property for the java path
  const config = vscode.workspace.getConfiguration("cfml-formatter");
  const ting = config.inspect("javaPath");
  let javaPath = config.get("javaPath");
  if (javaPath) {
    LOG.info("Java Path from config: [{}]", javaPath);
  }
  else {
    javaPath = defaultJavaPath
    LOG.info("Java Path from default", defaultJavaPath);
  }


  lspjar = path.join(context.extensionPath, 'resources', lspfilename);

  // const javaVersion = await checkJavaVersion(javaPath);
  // LOG.info("Java Version", javaVersion);

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
    window.withProgress({
      location: vscode.ProgressLocation.Notification,
      title: "Starting Lucee LSP Server",
      cancellable: false
    }, async (progress, token) => {
       
      }
    );

    // startServer(javaPath, [`-Dlucee.lsp.port=${lspPort}`, `-Dlucee.server.port=${serverPort}`, `-Dlucee.server.wardir=/tmp`, "-jar", lspjar], outputChannel);

    luceeServer = await startServer(javaPath, [`-Dlucee.lsp.port=${lspPort}`, `-Dlucee.server.port=${serverPort}`, `-Dlucee.server.wardir=/tmp`, "-jar", lspjar], outputChannel);

    LOG.info("Started Lucee LSP Server");
  }
  else {
    LOG.info("Not Starting Lucee LSP Server, using existing server on port {}", lspPort);
  }
  
  LOG.info("Connecting to Lucee LSP Server on port: {}", lspPort);
  const socketTimeout = 5000;

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

      // NOTICE: Do not add a setTimeout to the socket! It will cause the connection to be closed after the timeout.
      // // Optional timeout handling
      // socket.setTimeout(socketTimeout, () => {
      //   console.error("Connection timeout");
      //   socket.destroy();
      //   reject(new Error("Connection timeout"));
      // });

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



  // const serverOptions = async () => {

  //   // const javaArgs = [`-Dlucee.lsp.port=${lspPort}`, `-Dlucee.server.port=${serverPort}`, `-Dlucee.server.wardir=/tmp`, "-jar", lspjar];
  //   // const javaArgsStr = javaArgs.join(" ");
  //   // // LOG.info(`Starting on LSP via: ${javaPath} ${javaArgsStr}`);
  //   // outputChannel.appendLine(`Starting on LSP From: ${lspjar} with args: ${javaArgs}`);

  //   // luceeServer = await startServer(javaPath, javaArgs);
  //   // await new Promise(r => setTimeout(r, 5000));
  //   // // LOG.info(luceeServer);
  //   // outputChannel.appendLine(`Lucee LSP Server Started after 5 seconds`);
  //   // // console.log(luceeServer);
  //   // return startSocket();
  //   return new Promise((resolve, reject) => { resolve({}) });
  // };


  // const options = {
  //   outputChannel,
  //   javaPath,
  //   lspPort,
  //   httpPort: serverPort,
  //   lspjar,
  //   wardir: context.globalStorageUri.fsPath
  // };

  // console.log("Starting with options", options);

  // initTasks.push(withSpinningStatus(context, async status => {
  // serverOptions = () => spawnLanguageServerProcessAndConnectViaTcp(options);
  // }));
  // initTasks.push(serverOptions());

  // console.log("Server Options", serverOptions);

  // Options to control the language client
  const clientOptions: LanguageClientOptions = {
    // Register the server for all documents by default
    documentSelector: [{ scheme: "file", language: "cfml" }],
    synchronize: {
      // Notify the server about file changes to '.cfformat files contained in the workspace
      fileEvents: [workspace.createFileSystemWatcher("**/.cfformat.json"), workspace.createFileSystemWatcher("**/.cfformat")],
      configurationSection: "cfml-formatter"
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
  return new Promise((resolve, reject) => {
    const javaVersion = child_process.spawn(javaPath, ["-version"]);
    let output = "";
    javaVersion.stdout.on("data", (data) => {
      output += data.toString();
      LOG.info("Java Version", output);
    });
    javaVersion.stderr.on("data", (data) => {
      output += data.toString();
    });
    javaVersion.on("close", (code) => {
      if (code === 0) {
        resolve(output);
      } else {
        reject(output);
      }
    });
  });
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