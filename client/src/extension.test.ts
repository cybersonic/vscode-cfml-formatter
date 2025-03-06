import * as child_process from "child_process";
// import { getJavaVersion } from "./extension";
import { LOG } from "./utils/logger";
import { beforeEach, describe, it, jest } from "@jest/globals";

jest.mock("child_process");
jest.mock("./utils/logger");

xdescribe("getJavaVersion", () => {
    const mockSpawn = child_process.spawn as jest.Mock;
    const mockInfo = LOG.info as jest.Mock;

    beforeEach(() => {
        jest.clearAllMocks();
    });


    // xit("should resolve with Java version output on success", async () => {
    //     const javaPath = "/usr/bin/java";
    //     const mockStdout = {
    //         on: jest.fn((event, callback) => {
    //             if (event === "data") {
    //                 callback("java version \"1.8.0_231\"\n");
    //             }
    //         }),
    //     };
    //     const mockStderr = {
    //         on: jest.fn(),
    //     };
    //     const mockProcess = {
    //         stdout: mockStdout,
    //         stderr: mockStderr,
    //         on: jest.fn((event, callback) => {
    //             if (event === "close") {
    //                 // callback(0);
    //             }
    //         }),
    //     };

    //     mockSpawn.mockReturnValue(mockProcess as any);

    //     const result = await getJavaVersion(javaPath);
    //     expect(result).toBe("java version \"1.8.0_231\"\n");
    //     expect(mockInfo).toHaveBeenCalledWith("Java Version", "java version \"1.8.0_231\"\n");
    // });
    /*
    it("should reject with error output on failure", async () => {
        const javaPath = "/usr/bin/java";
        const mockStdout = {
            on: jest.fn(),
        };
        const mockStderr = {
            on: jest.fn((event, callback) => {
                if (event === "data") {
                    callback("Error: Could not find Java version\n");
                }
            }),
        };
        const mockProcess = {
            stdout: mockStdout,
            stderr: mockStderr,
            on: jest.fn((event, callback) => {
                if (event === "close") {
                    callback(1);
                }
            }),
        };

        mockSpawn.mockReturnValue(mockProcess as any);

        await expect(getJavaVersion(javaPath)).rejects.toBe("Error: Could not find Java version\n");
    });
    */
});