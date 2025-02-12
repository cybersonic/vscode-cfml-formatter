
component extends="testbox.system.BaseSpec"{

    function run( testResults, testBox ){
        // all your suites go here.
        describe( "Workspace", function(){
            var sut = new lsp.methods.Workspace();
            it( "should do the diagnostic", function(){
                
               var configStore = new lsp.ConfigStore(  );
                configStore.setConfig(
                    { 'rootPath': '/Users/markdrew/Code/DistroKid/VSCode/lsp-example-workspace' }
                );
                var console = createEmptyMock("lsp.Console");
                // sut.setBeanFactory( ioc );
                sut.setConsole( console );
                sut.setConfigStore( configStore );

                var ret = sut.diagnostic( {} );

                debug(ret);

            } );

        } );
    }

}
