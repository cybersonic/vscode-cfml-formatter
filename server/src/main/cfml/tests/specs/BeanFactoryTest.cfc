component extends="testbox.system.BaseSpec"{
    /*********************************** BDD SUITES ***********************************/

    function run( testResults, testBox ){
        // all your suites go here.
        describe( "Configuration", function(){
            
            
            it( "should be able to get all the base beans for LSP", function(){

                var ioc = new framework.ioc( "/lsp" );
                ioc.declare( "$" ).instanceOf( "lsp.methods.Util" );

                expect( ioc.containsBean( "lifecycle" ) ).toBeTrue();
                expect( ioc.containsBean( "textDocument" ) ).toBeTrue();
                expect( ioc.containsBean( "workspace" ) ).toBeTrue();
                expect( ioc.containsBean( "Console" ) ).toBeTrue();
                expect( ioc.containsBean( "$" ) ).toBeTrue();
            });

            
            it( "should populate via constructor", function(){
                var ioc = new framework.ioc( "/tests/components" );
                debug(ioc);
                var singleton = ioc.getBean( "Singleton" );
                debug(singleton);
                var constructoBean = ioc.getBean( "ConstructorBean" );
                debug(constructoBean)
                var propertyBean = ioc.getBean( "PropertyBean" );
                debug(propertyBean)
                debug(propertyBean.getSingleton());
            });
            
            

        } );
    }

}
