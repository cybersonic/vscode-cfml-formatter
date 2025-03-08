component accessors=true {

    property name="LSPServer";
    property name="ConfigStore";
    property name="TextDocumentStore";
    property name="Console";
    


    function init() {
        return this;
    }

    function configuration(message) {
        getConfigStore().setConfig(message.params);

        return {'result': {}};
    }

    function didChangeConfiguration(message) {
        // console.log("Did Change Configuration", message);
        //  "params":{"settings":{"cfml-formatter":{"javaPath":"/usr/bin/java"}}}}
        // TODO: Update the configuration if we change it
        // var config = variables.lspserver.getConfig();
        // for(var change in message.params.settings){

        // }
        // store.addMessage("null", "workspace/configuration", "request", message);
        // lspEndpoint.sendMessageToClient(message);
    }

    function didChangeWatchedFiles(message) {
        // console.log("Did Change Watched Files", message);
        // export const Created = 1;
        // /**
        //  * The file got changed.
        //  */
        // export const Changed = 2;
        // /**
        //  * The file got deleted.
        //  */
        // export const Deleted = 3;
        param name="message.params.changes" type="array" default=[];

        console.log('Did Change Watched Files', message);
        // for (var change in message.params.changes) {
        //     // Update or add if changed or created
        //     if (change.type EQ 1 OR change.type EQ 2) {


        //         server.documents[change.uri] = fileRead(replace(change.uri, 'file://', ''));
        //     }
        //     if (change.type EQ 3) {
        //         server.documents.delete(change.uri);
        //     }
        // }

        // store.addMessage("null", "workspace/configuration", "request", message);
        // lspEndpoint.sendMessageToClient(message);
    }



    function onMissingMethod(required string methodName, required array args) {
        console.log('Missing Workspace Method', methodName, args);
    }
}