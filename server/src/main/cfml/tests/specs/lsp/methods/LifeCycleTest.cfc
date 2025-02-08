component extends="testbox.system.BaseSpec" {
    function run(){
        describe("Lifecycle", function(){
            
            it( "should have the right methods", function(){

                var sut = new lsp.methods.Lifecycle({}, {});
                expect( sut ).toHaveKey( "initialize" );
                expect( sut ).toHaveKey( "initialized" );
                expect( sut ).toHaveKey( "shutdown" );
                expect( sut ).toHaveKey( "exit" );
            
            });
            
            it("should return the initialize system", function(){
                var sut = new lsp.methods.Lifecycle({}, {});
                var ret = sut.initialize({});
                debug(ret);
                expect( ret ).toHaveKey( "result" );
                expect( ret.result ).toHaveKey( "capabilities" );
            });
            it("should return initialized", function(){
                var sut = new lsp.methods.Lifecycle({}, {});
                var ret = sut.initialized({});
                debug(ret);
                expect( ret ).toHaveKey( "result" );
                
            });
            it("should return shutdown", function(){
                var sut = new lsp.methods.Lifecycle({}, {});
                var ret = sut.shutdown({});
                debug(ret);
                expect( ret ).toHaveKey( "result" );
                
            });
            it("should return exit", function(){
                var sut = new lsp.methods.Lifecycle({}, {});
                var ret = sut.exit({});
                debug(ret);
                expect( ret ).toHaveKey( "result" );
                expect( ret.result ).toBe(1);
                
            });
            
        });
    }
}