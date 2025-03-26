const fs = require('fs');


export function isExecutableFile(filePath) {
    try {
        // Check if the file exists
        if (!fs.existsSync(filePath)) {
            return false;
        }

        // Check that it is a file
        const stats = fs.statSync(filePath);
        if (!stats.isFile()) {
            return false;
        }

        // Check that the file is executable.
        // fs.constants.X_OK checks for execute permission.
        fs.accessSync(filePath, fs.constants.X_OK);

        return true;
    } catch (error) {
        return false;
    }
}
