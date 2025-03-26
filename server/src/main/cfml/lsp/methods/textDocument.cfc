component accessors="true" {

    import java.net.URL;
    property name="documents";
    property name="LSPServer";
    property name="ConfigStore";
    property name="Console";
    property name="CFFormat";
    property name="TextDocumentStore";
    property name="beanFactory";

    public function init() {
        return this;
    }

    private textDocumentItem function updateDocument(required struct textDocument) {
        var textDocumentItem = getTextDocumentStore().saveTextDocument(textDocument);
        return textDocumentItem;
    }

    public void function didClose(required struct message) {
        // console.log("Did Close", message);
        getTextDocumentStore().deleteDocument(message.params.textDocument.uri);
    }
    public void function didOpen(required struct message) {
        updateDocument(message.params.textDocument);
    }


    public void function didChange(required struct message) {
        // TODO: Check what is in the content Changes. We are doing full sync for now.
        console.log('didChange', message.params);

        var textDocument = {
            'uri': message.params.textDocument.uri,
            'version': message.params.textDocument.version,
            'text': message.params.contentChanges[1].text
        };
        updateDocument(textDocument);

        // variables.lspserver

        // var diagnostics = diagnostic(message);

        // var lspEndpoint =  variables.lspserver.getLspEndpoint();
        //     lspEndpoint.sendMessageToClient(diagnostics);
    }

    public struct function completion(required struct message) {
        // Returns a completion thing.

        return {
            'jsonrpc': '2.0',
            'id': message.id,
            'result': [{'label': 'test'}, {'label': 'test1'}, {'label': 'test2'}]
        }
    }

    /**
     * This returns the config file contents, or {} if none found
     * @from the file from where to search , in the format file:///Users/etc.
     * @to usually the root of the worspace.
     * @return the path to a file
     */
    private string function findConfigFile(from, to) {
        // Make them into URIs.
        var fromFile = new URL("file://" & from);
        var fromPath = getDirectoryFromPath(fromFile.getPath());
        var toDir = new URL("file://" & to);
        var toPath = toDir.getPath();

        // var prefix = "file://";


        param name="server.documents" default="#{}#";

        // If we have an item next to it. But we should look in the docs first.
        var nearestCFFormat = fromPath & '.cfformat.json';

        
        // Otherwise check the actual filesystem
        if (fileExists(fromPath & '.cfformat.json')) {
            // dump("Found in Filesystem #fromPath#.cfformat.json");
            return fromPath & '.cfformat.json';
        }

        var fromPathArr = listToArray(fromPAth, '/');
        var toPathArr = listToArray(toPath, '/');

        
        loop from="#fromPathArr.len()#" to="#toPathArr.len()#" step="-1" index="dirIndex" {
            var formatFilePath = arraySlice(fromPathArr, 1, dirIndex).toList('/');
            formatFilePath = '/' & formatFilePath & '/.cfformat.json';

            var nearestCFFormat = formatFilePath;

            // if (server.documents.keyExists(nearestCFFormat)) {
            //     // dump("Found in Server #nearestCFFormat#");
            //     return server.documents[nearestCFFormat];
            // }
            // Otherwise check the actual filesystem
            if (fileExists(formatFilePath)) {
                return  formatFilePath;
            }
        }

        // If we didnt find it with all of the above, try to read the one from the config

        var settings = getConfigStore().getSettings();
        var configDefaultFile = settings['cfml-formatter']['defaultConfig'] ?: '';

        if (fileExists(configDefaultFile) && isJSON(fileRead(configDefaultFile))) {
            console.log("Found in Config Default File", configDefaultFile);
            return configDefaultFile;
        }
        return '';
    }


    /**
     * TODO: implement
     *
     * @message
     */
    private function rangeFormatting(required struct message) {
        var cfformatPath = expandPath('/cfformat/');
        variables.cfformat = new cfformat.models.CFFormat(cfformatPath & 'bin/', cfformatPath);
        // get the docuiment append something to it and do some magic.
        fileSetAccessMode(cfformatPath & 'bin/cftokens', '777');

        var theDoc = _getDoc(message.params.textDocument.uri);
        var range = message.params.range;
        var lines = getLines(theDoc);
        var selectedLines = arraySlice(lines, range.start.line + 1, range.end.line - range.start.line + 1);

        selectedLines = selectedLines.toList(server.separator.line);
        var extension = listLast(message.params.textDocument.uri, '.');
        var filename = '/tmp/#hash(message.params.textDocument.uri)#.#extension#';

        fileWrite(filename, selectedLines);
        var settings = {};

        // This gets the actual config as JSON
        var configFile = findConfigFile(message.params.textDocument.uri, getConfigStore().getConfig().rootUri);
        if (!isNull(configFile) && isJSON(server.documents[configFile])) {
            settings = deserializeJSON(server.documents[configFile]);
        }
        var formattedDoc = getCFFormat().formatFile(filename, settings);
        return {'jsonrpc': '2.0', 'id': message.id, 'result': [{'range': range, 'newText': formattedDoc}]};
    }


    public struct function formatting(required struct message) {
        var theDoc = getTextDocumentStore().getDocument(arguments.message.params.textDocument.uri);
        var defaultSettingsPath = getConfigStore().getSettings();
        // Need to return an error , rather than a blank result.
        if (isNull(theDoc)) {
            return {'jsonrpc': '2.0', 'id': message.id, 'result': []}
        }
        // Have to save the file to disk and then run the formatter on it.
        var extension = listLast(message.params.textDocument.uri, '.');
        var filename = '/tmp/#hash(message.params.textDocument.uri)#.#extension#';

        fileWrite(filename, theDoc);
        var settings = {};
        var rootURI = getConfigStore().getConfig().rootURI;
        
        // All the findConfigFile stuff should be in one function, we should do finding and returning of the config. 
        var loadSettings = findConfigFile(message.params.textDocument.uri, rootURI);

        
        if (Len(loadSettings)) {
            showClientLog('info', 'Loading settings from ' & loadSettings);
            var rawSettings = FileRead(loadSettings);
            settings = deserializeJSON(rawSettings);
        }
        else {
            showClientMessage('warning', 'No formatting settings found. Using Default');
            showClientLog('warning', 'No formatting settings found. Using Default');
        }


        try {
             // console.log("Config Settings", settings);
            var originalLines = getLines(theDoc);
            var formattedDoc = getCFFormat().formatFile(filename, settings);
            // Send a message to the client to let them know what we are formatting with 
            // getLSP('info', 'Formatting with settings');
            return {
                'jsonrpc': '2.0',
                'id': message.id,
                'result': [
                    {
                        'range': {
                            'start': {'line': 0, 'character': 0},
                            'end': {'line': originalLines.len(), 'character': originalLines.last().len()}
                        },
                        'newText': formattedDoc
                    }
                ]
            }
        } catch (ext) {
            // Need to decorate with the file. 
            var message  = '#ext.message# in #message.params.textDocument.uri#';
            showClientMessage('error', message);
            showClientLog('error', message);
            
            return {
                'jsonrpc': '2.0',
                'id': message.id,
                'error': {
                    'code':  -32700,
                    'message':message,
                    'data': ext
                }
            }


            // throw(ext);
        }
       
    }

    private void function showClientLog(string type = "info", string message) {
        sendClientMessage(type, message, "window/logMessage");
    }
    private void function showClientMessage(string type = "info", string message) {

        sendClientMessage(type, message, "window/showMessage");
    }

    private function sendClientMessage(string type,string message, method="window/showMessage") {
        var types = {
            'info': 3,
            'warning': 2,
            'error': 1
        };
        var message = {
            'jsonrpc': '2.0',
            'method': arguments.method,
            'params': {
                'type': types[arguments.type],
                'message': arguments.message
            }
        };
        var instance=createObject("java","lucee.runtime.lsp.LSPEndpointFactory").getExistingInstance();
        instance.sendMessageToClient(message, false);
    }

    private function getLines(required string text) {
        var lines = listToArray(text, chr(10) & chr(13), true);
        return lines;
    }
    private function getCharacters(required string text) {
        return listToArray(text, '', true);
    }

    public void function onMissingMethod(required string methodName, required array args) {
        getConsole().log('Missing Method', methodName, args);
    }



    // public any function convertTagToScript(required string tagCFML) {

    //     var toScript =  new cfscriptme.models.toscript.ToScript();
    //     var ret = toScript.toScript(fileContent=tagCFML);

    //     return ret;
    // }

    // public any function codeAction(required struct message){
    //     console.log(message);
    //     return {
    //         "jsonrpc": "2.0",
    //         "id": message.id,
    //         "result": [

    //             'refactor.rewrite'

    //         ]

    //     }
    // }

}
