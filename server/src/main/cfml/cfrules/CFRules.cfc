component accessors="true" {

    property name="rulesFileName" type="string" default=".cfrules.json";
    property name="rules";
    property name="rootPath";

    function init(struct rules = '{}', string rootPath = '/tmp') {
        setRules(arguments.rules);
        if (!arguments.rootPath.endsWith(server.separator.file)) {
            arguments.rootPath &= server.separator.file;
        }
        setRootPath(arguments.rootPath);
        return this;
    }


    function getWorkspaceIssues() {
        var ret = [];
        for (var rule in getRules().workspace) {
            if (!rule.keyExists('value')) {
                throw('Key named [value] is required for the [#rule.type#] rule');
            }
            switch (rule.type) {
                case 'extension_not_allowed':
                    ret.append(extension_not_allowed(rule), true);
                    break;
                case 'folder_not_allowed':
                    ret.append(folder_not_allowed(rule), true);
                    break;
            }
        }
        return ret;
    }

    function getTextDocumentIssues(fileUri){
        var ret = [];
        for (var rule in getRules().textDocument) {
            if (!rule.keyExists('value')) {
                throw('Key named [value] is required for the [#rule.type#] rule');
            }
            switch (rule.type) {
                case 'query_in_cfm':
                    var foundItems = find_token_in_file(rule);

                    ret.append(extension_not_allowed(rule), true);
                    break;
                // case 'folder_not_allowed':
                //     ret.append(folder_not_allowed(rule), true);
                //     break;
            }
        }
        return ret;
    }

    /**
     * extension_not_allowed checks for file extensions defined in the `value` key of the rule an makes sure that it is not present in the directory defied in the `path` key
     *
     * @rule 
     */
    array function extension_not_allowed(struct rule) {
        var foundItems = [];
        var path = getRootPath() & (rule.path ?: '');
        if (!localDirectoryExists(path)) {
            throw('Directory [#path#]  does not exist');
        }


        var files = localDirectoryList(
            path: path,
            recurse: true,
            listInfo: 'array',
            filter: '#rule.value#',
            type: 'file'
        );



        var foundItems = files.map(function(file) {
            // Get the end line
            var content = localfileRead(file);
            var lines = listToArray(content, server.separator.line, true);
            

            var linecount = lines.len() - 1;
            if (linecount < 0) {
                linecount = 0;
            }

            var ret = {
                'range': {'start': {'line': 0, 'character': 0}, 'end': {'line': linecount, 'character': 0}},
                'severity': rule.severity,
                'message': rule.message,
                'code': "extension_not_allowed",
                'source': 'CFRules',
                'uri': 'file://' & file,
                // 'tags': []
            };

            // 'codeDescription':{
            //         'href': "https://google.com"
            //     },
            if(rule.keyExists('href')){
                ret["codeDescription"] = {
                    'href': rule.href
                };
            }
            return ret;
        });

        return foundItems;
    }

    /**
     * folder_not_allowed checks for folders defined in the `value` key of the rule an makes sure that it is not present in the directory defied in the `path` key
     *
     * @rule 
     */array function folder_not_allowed(struct rule) {
        var foundItems = [];
        var path = getRootPath() & (rule.path ?: '');
        if (!localDirectoryExists(path)) {
            throw('Directory [#path#]  does not exist');
        }
        var folders = localDirectoryList(
            path: path,
            recurse: true,
            listInfo: 'array',
            filter: '#rule.value#',
            type: 'dir'
        );

        var foundItems = folders.map(function(folder) {

            var ret = {
                'range': {'start': {'line': 0, 'character': 0}, 'end': {'line': 0, 'character': 0}},
                'severity': rule.severity,
                'message': rule.message,
                'code': "folder_not_allowed",
                'source': 'CFRules',
                'uri': 'file://' & folder
            };

            if(rule.keyExists('href')){
                ret["codeDescription"] = {
                    'href': rule.href
                };
            }
           
            return ret;
        });

        return foundItems;
    }


    string function localFileRead(required string path){
        return fileRead(arguments.path);
    }
    boolean function localDirectoryExists(required string path){
        return directoryExists(arguments.path);
    }

    array function localDirectoryList(required string path, boolean recurse=false, string listInfo = 'query', string filter = '', string type = 'all'){
        dump(arguments);
        
        var dirList = directoryList(
            path: arguments.path,
            recurse: arguments.recurse,
            listinfo: arguments.listInfo,
            filter: arguments.filter,
            type: arguments.type
        );
        
        return dirList;
    }
}
