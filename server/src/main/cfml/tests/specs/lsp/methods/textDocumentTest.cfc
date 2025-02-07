component extends="testbox.system.BaseSpec" {

    function run(){




        
        describe( "Diagnostics", function(){
        
          var textDocument =  new lsp.methods.textDocument({}, {});
          var ret = textDocument.diagnostic({
            "jsonrpc": "2.0",
            "id": 1,
            "method": "textDocument/diagnostic",
            "params": {
              "textDocument": {
                "uri": "file:///path/to/file.cfc"
              }
            }
          });

          debug(ret);
          
        });
    }
}

