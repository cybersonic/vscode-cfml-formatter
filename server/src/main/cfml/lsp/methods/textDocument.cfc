component {
    import java.net.URL;
    property name="documents";

    function init(lspserver, logger){
        variables.lspserver = lspserver;
        variables.console = logger;

       
        var cfformatPath=expandPath('/cfformat/');

        // // get the docuiment append something to it and do some magic. 
    
        // fileSetAccessMode(cfformatPath & "bin/cftokens", "777");
        fileSetAccessMode(cfformatPath & "bin/cftokens_osx", "777");
        fileSetAccessMode(cfformatPath & "bin/cftokens_linux", "777");
        fileSetAccessMode(cfformatPath & "bin/cftokens_linux_musl", "777");
        
        variables.cfformat = new cfformat.models.CFFormat(cfformatPath & "bin/", cfformatPath);
    }


    

    function updateDocument( required string uri, required string text ){
        server.documents[uri] = text;
    }

    function deleteDocument( required string uri ){
        if(server.documents.keyExists(uri)){
            server.documents.delete(uri);
        }
    }
    function getDocuments(){
        return server.documents;
    }

    private function _getDoc( required string uri ){
        if(!server.documents.keyExists(uri)){
            return "";
        }
        return server.documents[uri];
    }
    void function didClose( required struct message ){
        // console.log("Did Close", message);
        deleteDocument(message.params.textDocument.uri)
    }
    void function didOpen( required struct message ){
        updateDocument(message.params.textDocument.uri, message.params.textDocument.text);
    }
    void function didChange( required struct message ){
        // TODO: Check what is in the content Changes. We are doing full sync for now.
        updateDocument(message.params.textDocument.uri, message.params.contentChanges[1].text);

        // variables.lspserver 

        var diagnostics = diagnostic(message);

        var lspEndpoint =  variables.lspserver.getLspEndpoint();
            lspEndpoint.sendMessageToClient(diagnostics);
    }
    
    function completion(required struct message){
        // Returns a completion thing.

        return {
            "jsonrpc": "2.0",
            "id": message.id,
            "result": [
                {
                    "label": "test",
                },
                {
                    "label": "test1",
                },
                {
                    "label": "test2",
                }
            ]

        }
    }

    /**
     * This returns the config file contents, or {} if none found
     * @from the file from where to search , in the format file:///Users/etc. 
     * @to usually the root of the worspace. 
     */
    public string function findConfigFile(from, to){
        // Make them into URIs. 
        var fromFile = new URL(from);
        var fromPath = getDirectoryFromPath(fromFile.getPath());
        var toDir = new URL(to);
        var toPath = toDir.getPath();

       
        
        
        param name="server.documents" default="#{}#";

        // If we have an item next to it. But we should look in the docs first. 
        var nearestCFFormat = "file://" & fromPath & ".cfformat.json";
      
        if(server.documents.keyExists(nearestCFFormat)){
            return server.documents[nearestCFFormat];
        }
        // Otherwise check the actual filesystem
        if(fileExists(fromPath & ".cfformat.json")){
            // dump("Found in Filesystem #fromPath#.cfformat.json");
            return FileRead(fromPath & ".cfformat.json");
        }

        var fromPathArr = listToArray(fromPAth, "/");
        var toPathArr = listToArray(toPath, "/");
           

        loop from="#fromPathArr.len()#" to="#toPathArr.len()#" step="-1" index="dirIndex" {
            var formatFilePath = arraySlice(fromPathArr, 1, dirIndex).toList("/");
                formatFilePath = "/" & formatFilePath & "/.cfformat.json";
                
            var nearestCFFormat = "file://" & formatFilePath;

            if(server.documents.keyExists(nearestCFFormat)){
                // dump("Found in Server #nearestCFFormat#");
                return server.documents[nearestCFFormat];
            }
            // Otherwise check the actual filesystem
            if(fileExists(formatFilePath)){
                return FileRead(formatFilePath);
            }

        }   
        
        return "{}";
    }
    
    
    function rangeFormatting(required struct message){

      
        var cfformatPath=expandPath('/cfformat/');
        variables.cfformat = new cfformat.models.CFFormat(cfformatPath & "bin/", cfformatPath);
        // get the docuiment append something to it and do some magic. 
        fileSetAccessMode(cfformatPath & "bin/cftokens", "777");

        var theDoc = _getDoc(message.params.textDocument.uri);
        var range = message.params.range;
        var lines = getLines(theDoc);
        var selectedLines = arraySlice(lines, range.start.line + 1, range.end.line - range.start.line + 1) ;
        // Ignore chars for the moment, since it would not make sense. 
        // var firstLine = mid(selectedLines.First(), range.start.character + 1, selectedLines.First().len() - range.start.character);
        // var lastLine = mid(selectedLines.Last(), 1, range.end.character);
        // selectedLines[1] = firstLine;
        // selectedLines[selectedLines.len()] = lastLine;
        // dump(server.separator.line)
        selectedLines = selectedLines.toList(server.separator.line);
        var extension  = listLast(message.params.textDocument.uri, ".");
        var filename = "/tmp/#Hash(message.params.textDocument.uri)#.#extension#";
        // TODO: We might need to fake this, somehow?
        // if it is a cfm and doesnt have cfscript, since it's a range, add <cfscript></cfscript> around it.
        FileWrite(filename, selectedLines);
        var settings={};

        var configFile = findConfigFile(message.params.textDocument.uri, variables.lspserver.getConfig().rootUri);
        if(!isNull(configFile)){
            if(server.documents.keyExists(configFile) && isJSON(server.documents[configFile])){
                
                settings = deserializeJson(server.documents[configFile]);
            }
        }
        var formattedDoc  = variables.cfformat.formatFile(filename,settings);
        return {
            "jsonrpc": "2.0",
            "id": message.id,
            "result": [
                {
                    "range": range,
                    "newText": formattedDoc
                }
            ]

        };
    }



    // public function diagnostic(required struct message){

    //     return {
    //         "jsonrpc": "2.0",
    //         "id": message.id,
    //         "result": {
    //           "kind": "full",
    //           "items": [
    //             {
    //                 "range": {
    //                     "start": { "line": 3, "character": 5 },
    //                     "end": { "line": 3, "character": 49 }
    //                 },
    //                 "severity": 2,
    //                 "code": "CFML1001",
    //                 "source": "cfml",
    //                 "message": "Unexpected token in CFML expression."
    //             }
    //           ]
    //         }
    //       }
    // }
          

    public struct function formatting(required struct message){
    
      
        param name="server.documents" type="struct" default=StructNew();
        var theDoc = _getDoc(arguments.message.params.textDocument.uri);
        
        // Have to save the file to disk and then run the formatter on it.
        var extension  = listLast(message.params.textDocument.uri, ".");
        var filename = "/tmp/#Hash(message.params.textDocument.uri)#.#extension#";

        FileWrite(filename, theDoc);
        // TODO: figure out how we get these, either from file or as a .cfformat file 
        var settings={};
        var loadSettings = findConfigFile(message.params.textDocument.uri, variables.lspserver.getConfig().rootURI);
        if(isJSON(loadSettings)){
            settings = deserializeJSON(loadSettings);
        }
        // console.log("Config Settings", settings);
        
        var originalLines = getLines(theDoc);

        var formattedDoc  = variables.cfformat.formatFile(filename,settings);
        // console.log(formattedDoc);
        // var lines = getLines(formattedDoc);

        // var lspEndpoint =  variables.lspserver.getLspEndpoint(); 
        // if(!isNull(lspEndpoint)){
          
        //     lspEndpoint.sendMessageToClient({
        //         "jsonrpc": "2.0",
        //         "id": 1,
        //         "method": "window/showMessageRequest",
        //         "params": {
        //             "type": 3,
        //             "message": "Document Formatted"
        //         }
        //     });
        // }

        return {
            "jsonrpc": "2.0",
            "id": message.id,
            "result": [
                {
                    "range": {
                        "start": { "line": 0, "character": 0 },
                        "end" : { "line": originalLines.len(), "character": originalLines.last().len()}
                    },
                    "newText": formattedDoc
                }
            ]

        }
    }

    private function getLines( required string text ){
        
        var lines = ListToArray(text, chr(10)&chr(13), true);
        return lines;
    }
    private function getCharacters( required string text ){
        return ListToArray(text, "", true);
    }

    function onMissingMethod(required string methodName, required array args){
        console.log("Missing Method", methodName, args);
    }

    

    public any function convertTagToScript(required string tagCFML) {
        
        var toScript =  new cfscriptme.models.toscript.ToScript();
        var ret = toScript.toScript(fileContent=tagCFML);
        
        return ret;
    }
    
    public any function codeAction(required struct message){
        console.log(message);
        return {
            "jsonrpc": "2.0",
            "id": message.id,
            "result": [
                
                'refactor.rewrite'
                
            ]

        }
    }
}
