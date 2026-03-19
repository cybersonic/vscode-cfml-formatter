/**
 * Component that Stores all the documents
 **/
component accessors=true {

    property name="documents";
    property name="beanFactory";

    function init() {
        setDocuments({});
        return this;
    }

    public any function getDocument(required string uri) {
        if (variables.documents.keyExists(uri)) {
            return variables.documents[uri];
        }
        return nullValue();
    }


    public void function updateDocument(required TextDocumentItem textDocument) {
        var uri = textDocument.getURI();

        if (!isNull(uri) && len(uri)) {
            variables.documents[uri] = textDocument;
        }
    }

    public void function deleteDocument(required string uri) {
        variables.documents.delete(uri);
    }


    public textDocumentItem function saveTextDocument(required struct textDocument) {
        // TODO: Move this to the TextDocumentStore
        var textDocumentItem = getBeanFactory().injectProperties('textDocumentItem', arguments.textDocument);
        var cfformat = getBeanFactory().getBean('CFFormat');

        var uri = textDocumentItem.getURI();
        var text = textDocumentItem.getText();

        /* Added support for Windows */
        // write it
        var fileHash = '/tmp/#hash(uri)#';
        var fileExtension = lCase(listLast(uri, '.'));
        var fileName = '#fileHash#.#fileExtension#';
        if (!directoryExists(expandPath('/tmp'))) {
            directoryCreate(expandPath('/tmp'));
        }
        /* Added support for Windows */
        fileWrite(fileName, text, 'utf-8');

        // Also need to check if we are formating during save.

        if (fileExtension == 'cfc' OR fileExtension == 'cfm' OR fileExtension == 'cfml') {

            /* Added support for Windows */
            // removed cftokens calls - formatting will call these when needed
        }

        updateDocument(textDocumentItem);
        return textDocumentItem;
    }

}
