import * as vscode from 'vscode';
import { LanguageClient, LanguageClientOptions, RevealOutputChannelOn, ServerOptions, StreamInfo } from "vscode-languageclient/node";
import { LOG } from './utils/logger';
import * as net from "net";
import { isOSUnixoid, isOSWindows } from './utils/osUtils';
import * as child_process from "child_process";

const LSPStartupString = "Lucee Language Server is now running";

export function startServer(javaPath, javaArgs, outputChannel) {

    return new Promise((resolve, reject) => {
        const luceeServer = child_process.spawn(javaPath, javaArgs, {
            stdio: 'pipe', // Pipe stdout/stderr for debugging/logging
        });

        // Log server output for debugging
        luceeServer.stdout.on('data', (data) => {
            outputChannel.appendLine(data.toString());
            LOG.info(data.toString());
            //do we resolve it
        });

        luceeServer.stderr.on('data', (data) => {
            outputChannel.appendLine(data.toString());
            LOG.info(data.toString());
            if (data.toString().includes("INFO: Starting ProtocolHandler")) {
                LOG.info("Server Started");
                resolve(luceeServer);
            }
        });

        luceeServer.on('close', (code) => {
            outputChannel.appendLine(`Lucee Language server exited with code ${code}`);
            LOG.info(`Lucee Language server exited with code ${code}`);

        });
        luceeServer.on('exit', (code) => {
            outputChannel.appendLine(`Lucee Language server exited with code ${code}`);
            LOG.info(`Lucee Language server exited with code ${code}`);
        });
    });
}
