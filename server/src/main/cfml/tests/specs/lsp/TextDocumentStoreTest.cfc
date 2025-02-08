component extends="testbox.system.BaseSpec"{
    function run( testResults, testBox ){
        // all your suites go here.
        describe( "TextDocumentStore", function(){

            var sut = new lsp.TextDocumentStore();
            it( "should store a Document", function(){
                sut.setDocuments({}); //clear the documents.

                var doc ={
                    "uri":"file:///Users/markdrew/Code/DistroKid/VSCode/lsp-example-workspace/Elvis.cfm",
                    "languageId":"cfml",
                    "version":1,
                    "text":"<cfscript></cfscript>"
                };

                var textDocument = new lsp.beans.textDocumentItem();
                    textDocument.setUri( doc.uri );
                    textDocument.setLanguageId( doc.languageId );
                    textDocument.setVersion( doc.version );
                    textDocument.setText( doc.text );

                var originalCount = sut.getDocuments().count();


                sut.updateDocument( textDocument );

                var docs = sut.getDocuments();
                expect(docs.count() ).toBeGT( originalCount );
               

                sut.setDocuments({}); //clear the documents.
                var textDocumentNoURI = new lsp.beans.textDocumentItem();
                var originalCount = sut.getDocuments().count();
                sut.updateDocument( textDocumentNoURI );
                
                var docs = sut.getDocuments();
                expect(docs.count() ).toBe( originalCount );


                // Should check for an empty or null URI.

               
            } );
            it( "should remove a Document", function(){
                sut.setDocuments({}); //clear the documents.
                var textDocumentWithURI = new lsp.beans.textDocumentItem();
                    textDocumentWithURI.setURI("testing");
                var originalCount = sut.getDocuments().count();
                sut.updateDocument( textDocumentWithURI );
                var docs = sut.getDocuments();
                expect(docs.count() ).toBeGT( originalCount );

                // Now remove it 

                sut.deleteDocument("testing");

                var docs = sut.getDocuments();
                expect(docs.count() ).toBe( originalCount );


                
            } );

        } );
    }

}
