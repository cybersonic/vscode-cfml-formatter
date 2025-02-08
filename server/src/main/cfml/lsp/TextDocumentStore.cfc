/**
 * Component that Stores all the documents
 **/
component accessors=true {

    property name="documents";
    property name="beanFactory";

    function init(){
        setDocuments({});
        return this;
    }

    public textDocumentItem function getDocument(required string uri){

        if(variables.documents.keyExists(uri) ){
            return variables.documents[uri];
        }
        return nullValue();

    }


    public void function updateDocument(required TextDocumentItem textDocument){
        var uri = textDocument.getURI();

        if(!isNull(uri) && len(uri)){
            variables.documents[uri] = textDocument;
        }
    }

    public void function deleteDocument(required string uri){
        variables.documents.delete(uri);
    }
}