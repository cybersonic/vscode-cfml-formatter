component accessors="true" {

    property name="ConfigStore";
    property name="TextDocumentStore";
    property name="LSPServer";
    property name="Console";
    property name="BeanFactory";

    variables.config = {};

    function initialize(message) {
        if (message.keyExists('params')) {
            getConfigStore().setConfig(message.params);
        }

        if (variables.config.keyExists('rootPath')) {
            // Now we got the configuration, lets read all the files to get the cfformat files.
            var cfformatfiles = directoryList(
                variables.config.rootPath,
                true,
                'array',
                '*.cfformat.json'
            );
            for (var file in cfformatfiles) {
                var content = fileRead(file);
                server.documents['file://' & file] = content;
            }
        }
        return {
            'result': {
                'capabilities': {
                    // "completionProvider": {},
                    /**
                     * Defines how text documents are synced. Is either a detailed structure
                     * defining each notification or for backwards compatibility the
                     * TextDocumentSyncKind number. If omitted it defaults to
                     * `TextDocumentSyncKind.None`.
                     */
                    'textDocumentSync': 1,
                    'documentFormattingProvider': true,
                    // "documentRangeFormattingProvider": true,
                    // 'diagnosticProvider': {'interFileDependencies': false, 'workspaceDiagnostics': true},
                    'diagnosticProvider': {'interFileDependencies': false, 'workspaceDiagnostics': false},
                    // "codeActionProvider": true,
                    'workspace': {
                        'workspaceFolders': {'supported': true, 'changeNotifications': true},
                        'configuration': true,
                        'didChangeConfiguration': true,
                        /**
                         * The client has support for file requests/notifications.
                         *
                         * @since 3.16.0
                         */
                        'fileOperations': {
                            /**
                             * The server is interested in receiving didCreateFiles
                             * notifications.
                             */
                            'didCreate': 'file',
                            /**
                             * The server is interested in receiving willCreateFiles requests.
                             */
                            'willCreate': 'file',
                            /**
                             * The server is interested in receiving didRenameFiles
                             * notifications.
                             */
                            'didRename': 'file',
                            /**
                             * The server is interested in receiving willRenameFiles requests.
                             */
                            'willRename': 'file',
                            /**
                             * The server is interested in receiving didDeleteFiles file
                             * notifications.
                             */
                            'didDelete': 'file',
                            /**
                             * The server is interested in receiving willDeleteFiles file
                             * requests.
                             */
                            'willDelete': 'file'
                        }
                    }
                }
            }
        };
    }

    function initialized(message) {
        return {'result': {}};
    }

    function shutdown(message) {
        server.documents = {};
        return {'result': {}};
    }
    function exit(message) {
        return {'result': 1};
    }

}