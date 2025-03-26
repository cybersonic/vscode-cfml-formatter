component extends="testbox.system.BaseSpec" {

    function run() {
        describe('format', () => {
            var documentStore = createMock('lsp.TextDocumentStore');


            var configStore = new lsp.ConfigStore(Config = {'rootURI': '/tmp'});


            var cfFormat = createMock('cfformat.models.CFFormat');
            cfFormat.$('formatFile', 'FORMATTED');

            var textDocument = new lsp.methods.textDocument();
            textDocument.setTextDocumentStore(documentStore);
            textDocument.setConfigStore(configStore);
            textDocument.setCFFormat(cfFormat);


            var td = new lsp.beans.TextDocumentItem(
                argumentCollection = {
                    'uri': 'file:///path/to/file.cfc',
                    'languageId': 'cfml',
                    'version': 1,
                    'text': '<cfscript></cfscript>'
                }
            );

            prepareMock(textDocument);
            textDocument.$('findConfigFile', '');
            textDocument.$('showClientMessage');
            textDocument.$('showClientLog');

            makePublic(textDocument, 'findConfigFile');

            documentStore
                .$('getDocument')
                .$args('file:///path/to/file.cfc')
                .$results(td);

            it('should format a document', function() {
                var ret = textDocument.formatting({
                    'jsonrpc': '2.0',
                    'id': 1,
                    'method': 'textDocument/format',
                    'params': {'textDocument': {'uri': 'file:///path/to/file.cfc'}}
                });

                expect(ret).toBeStruct();
                expect(ret).toHaveKey('jsonrpc');

                // TODO: Validate this struct to schema

                debug(ret);
            });
        });
        describe('updateDocument', () => {
            // Configure the BeanFactory:
            var console = createMock('lsp.Console');
            var beanFactory = new framework.ioc('/lsp');
            var textDocumentStore = createMock('lsp.TextDocumentStore');

            var cfformatPath = expandPath('/cfformat/');
            fileSetAccessMode(cfformatPath & 'bin/cftokens_osx', '777');
            fileSetAccessMode(cfformatPath & 'bin/cftokens_linux', '777');
            fileSetAccessMode(cfformatPath & 'bin/cftokens_linux_musl', '777');
            var cfformat = new cfformat.models.CFFormat(cfformatPath & 'bin/', cfformatPath);
            beanfactory.declare('CFFormat').asValue(cfformat);

            textDocumentStore.setBeanFactory(beanFactory);

            var textDocument = new lsp.methods.textDocument();
            textDocument.setConsole(console);
            textDocument.setBeanFactory(beanFactory);
            textDocument.setTextDocumentStore(textDocumentStore);

            makePublic(textDocument, 'updateDocument');


            var doc = {
                'uri': 'file:///Users/markdrew/Code/DistroKid/VSCode/lsp-example-workspace/Elvis.cfm',
                'languageId': 'cfml',
                'version': 1,
                'text': '<cfscript></cfscript>'
            };


            var ret = textDocument.updateDocument(doc);

            debug(ret);
            var tokens = ret.getTokens();
            var parsed = ret.getParsed();

            debug(tokens);

            expect(tokens).toBeTypeOf('array');
            expect(tokens.len()).toBeGT(0);

            debug(parsed);
            expect(parsed).toBeTypeOf('struct');
            expect(parsed.size()).toBeGT(0);
        });

        
        describe( "should find the config", function(){
            var textDocument = new lsp.methods.textDocument();
            makePublic(textDocument, 'findConfigFile');
            
            it( "should find an existing config in the path", function(){
            
                var formatFile = expandPath("/tests/resources/path/path1/path2/path3/formatme.cfm");
                var searchRoot = expandPath("/tests/resources/path/");
    
                var configFile = textDocument.findConfigFile(formatFile, searchRoot);
                expect(	configFile ).toBe(  expandPath("/tests/resources/path/.cfformat.json"));
                
                
                expect(	configFile.startsWith("file://") ).toBeFalse();
            });

            
            it( "should look for the default config if we didnt find it in the path", function(){

                // pretend we have some settings
                var configStore = new lsp.ConfigStore();
                var console = new lsp.Console();
                var settings = {
                    "cfml-formatter": {
                        "defaultConfig": expandPath("/tests/resources/path/.cfformat.json")
                    }
                }
                configStore.setSettings(settings);
                
                textDocument.setConfigStore(configStore);
                textDocument.setConsole(console);
            
                var formatFile = expandPath("/tests/resources/path/path1/path2/path3/formatme.cfm");
                var searchRoot = expandPath("/tests/resources/path/path1/");
    
                var configFile = textDocument.findConfigFile(formatFile, searchRoot);
                debug(configFile);                

                expect(	configFile.startsWith("file://") ).toBeFalse();
                // Should be the default config
                expect(	configFile ).toBe(settings["cfml-formatter"]["defaultConfig"] );
                
                
            });
            


            // This should return the file path
            // findConfigFile
            //

        
        });
    }

}

