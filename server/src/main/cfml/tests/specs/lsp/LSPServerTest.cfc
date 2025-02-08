
/**
 * My BDD Test
 */
component extends="testbox.system.BaseSpec"{

/*********************************** LIFE CYCLE Methods ***********************************/

    /**
     * executes before all suites+specs in the run() method
     */
    function beforeAll(){

    }

    /**
     * executes after all suites+specs in the run() method
     */
    function afterAll(){

    }

    /*********************************** BDD SUITES ***********************************/

    function run( testResults, testBox ){
        // all your suites go here.
        describe( "LSP Server", function(){
            var sut = new lsp.LSPServer();

            it( "should initialize everything", function(){
                sut.initialize();
                debug(sut);
            });

            
            it( "should accept a message", function(){

                var ret = sut.execute({
                    "jsonrpc": "2.0",
                    "id": 1,
                    "method": "textDocument/diagnostic",
                    "params": {
                        "textDocument": {
                            "uri": "file:///path/to/file.cfc"
                        }
                    }
                }, {});
            });

            
            it( "should handle an invalid object", function(){
                var ret = sut.execute({
                    "jsonrpc": "2.0",
                    "id": 1,
                    "method": "elvis/prestley",
                    "params": {
                        "textDocument": {
                            "uri": "file:///path/to/file.cfc"
                        }
                    }
                }, {});

                debug(ret);
                expect( isNull(ret.result) ).toBeTrue();
            });
        } );
    }

}
