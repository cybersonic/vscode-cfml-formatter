import * as vscode from "vscode";
import {
  LanguageClient,
  LanguageClientOptions,
  RevealOutputChannelOn,
  ServerOptions,
  StreamInfo,
} from "vscode-languageclient/node";
import { LOG } from "./utils/logger";
import * as net from "net";
import { isOSUnixoid, isOSWindows } from "./utils/osUtils";
import * as child_process from "child_process";

const LSPStartupString = "Lucee Language Server is now running";

const serverOutputChannel = vscode.window.createOutputChannel(
  "CFML Formatter Server"
);
export function startServer(javaPath, javaArgs) {
  return new Promise((resolve, reject) => {
    const luceeServer = child_process.spawn(javaPath, javaArgs, {
      stdio: "pipe", // Pipe stdout/stderr for debugging/logging
    });

    // Log server output for debugging
    luceeServer.stdout.on("data", (data) => {
      serverOutputChannel.appendLine(data.toString());
      LOG.info(data.toString());
      //do we resolve it
    });

    luceeServer.stderr.on("data", (data) => {
      serverOutputChannel.appendLine(data.toString());
      LOG.info(data.toString());
      if (data.toString().includes("INFO: Starting ProtocolHandler")) {
        LOG.info("Server Started");
        serverOutputChannel.appendLine("Server Started");
        resolve(luceeServer);
      }
    });

    luceeServer.on("close", (code) => {
      serverOutputChannel.appendLine(
        `Lucee Language server exited with code ${code}`
      );
      LOG.info(`Lucee Language server exited with code ${code}`);
    });
    luceeServer.on("exit", (code) => {
      serverOutputChannel.appendLine(
        `Lucee Language server exited with code ${code}`
      );
      LOG.info(`Lucee Language server exited with code ${code}`);
    });
  });
}
