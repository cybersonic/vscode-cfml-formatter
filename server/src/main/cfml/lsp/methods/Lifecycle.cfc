component {

    variables.config = {};

    function init(lspserver, logger){
        variables.lspserver = lspserver;
        variables.console = logger;
    }

    function getConfig(){
        return server.config;
    }
    

    function initialize(message) {
        
        if(message.keyExists("params")){
            server.config = message.params;
            
            // console.log("Setting the config", variables.config);
        }
        if(variables.config.keyExists("rootPath")){
            // Now we got the configuration, lets read all the files to get the cfformat files.
            var cfformatfiles = DirectoryList(variables.config.rootPath, true, "array", "*.cfformat.json");
            for(var file in cfformatfiles){
                var content = FileRead(file);
                server.documents["file://"&file] = content;
            }
        }
        return {
            "result": {
                "capabilities": {
                    // "completionProvider": {},
                    "textDocumentSync": 1,
                    "documentFormattingProvider": true,
                    // "documentRangeFormattingProvider": true,
                    "diagnosticProvider": {
                        "interFileDependencies": false,
                        "workspaceDiagnostics": false
                    },
                    // "codeActionProvider": true,
                    "workspace": {
                        "configuration": true,
                        "didChangeConfiguration": true
                    }
                }
            }
        };
    }

    function initialized(message) {
        return {
            "result": {}
        };
    }

    function shutdown(message) {
        server.documents = {};
        return {
            "result": {}
        };
    }
    function exit(message) {
        return {
            "result": 1
        };
    }
}