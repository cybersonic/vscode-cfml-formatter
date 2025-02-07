import { LOG } from "./logger";
import * as net from "node:net";
import { detect } from 'detect-port';


function tests() {
    console.log("Checking for ports");
    detect(4000).then((port) => {
        console.log("Port 4000 is available:", port);
    });
    detect(4001).then((port) => {
        console.log("Port 4001 is available:", port);
    });
}
/**
 * Check if a specific port is available.
 *
 * @param port - The port number to check.
 * @returns A promise that resolves to true if the port is available, false otherwise.
 */
export function isPortAvailable(port: number): Promise<boolean> {
    return new Promise((resolve) => {
        const server = net.createServer();

        server.once('error', (data) => {
            LOG.error("Error checking port {}", data);
            resolve(false); // Port is in use or inaccessible.
        });
        server.once('listening', (data) => {
            LOG.error("Started listening checking port {}", data);
            server.close(() => resolve(true)); // Port is available.
        });
        LOG.info("Checking port {}", port);
        server.listen(port);
    });
}

/**
* Find the next available port starting from a given port.
*
* @param startPort - The port number to start checking from.
* @returns A promise that resolves to the next available port or -1 if none is found.
*/
export async function findNextAvailablePort(startPort: number): Promise<number> {
    for (let port = startPort; port <= 65535; port++) {
        if (await isPortAvailable(port)) {
            return port;
        }
    }
    return -1; // No available port found.
}


tests();