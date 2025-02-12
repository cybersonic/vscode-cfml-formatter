
component extends="testbox.system.BaseSpec"{
    function run( testResults, testBox ){
        // all your suites go here.
        describe( "CFRules", function(){
            describe( "Workspace", function(){
                var sut = new cfrules.CFRules(
                    rules: {
                        "workspace": [
                            {
                                "type": "extension_not_allowed",
                                "path": "webroot/",
                                "value": "*.md",
                                "severity": 2,
                                "message": "Extension .md not allowed in webroot/"
                            },
                            {
                                "type": "extension_not_allowed",
                                "path": "webroot/",
                                "value": "*.php",
                                "severity": 2,
                                "message": "Extension [*.php] Not allowed under webroot/"
                            },
                            {
                                "type": "folder_not_allowed",
                                "path": "webroot/",
                                "value": "tests",
                                "severity": 2,
                                "message": "Folder tests not allowed in webroot/"
                            }
                        ]
                    }, 
                    rootPath: "/tmp"
                );
                prepareMock(sut);
                makePublic(sut, "localDirectoryExists");
                makePublic(sut, "localDirectoryList");

                
                it( "should add a slash at the end of the RootPath", function(){
                    var sut = new cfrules.CFRules({}, "/tmp");
                    expect(sut.getRootPath()).toBe("/tmp/");    
                });
            

                it( "extension_not_allowed", function(){

                    // Pretend the file exists. 
                    sut.$('localDirectoryExists').$args('/tmp/webroot/').$results(true);
                    sut.$('localDirectoryList').$args(
                        path="/tmp/webroot/",
                        recurse=true,
                        listInfo="array",
                        filter="*.md",
                        type="file").$results([
                            "/tmp/webroot/file.md"
                        ]);

                    sut.$('localFileRead').$args("/tmp/webroot/file.md").$results("content");
                        
                    var ret = sut.extension_not_allowed(
                        {
                            "type": "extension_not_allowed",
                            "path": "webroot/",
                            "value": "*.md",
                            "severity": 2,
                            "message": "Extension .md not allowed in webroot/"

                        }
                    );
                    debug( ret );
                    expect( ret ).toBeArray();
                    expect( ret[1].uri ).toBe("file:///tmp/webroot/file.md");
                    expect( ret[1].message ).toBe("Extension .md not allowed in webroot/");
                    expect( ret[1].severity ).toBe(2);
                    expect( ret[1].keyExists("codeDescription") ).toBe(false);
                } );

                
                it( "should add a codeDescription if we have a href", function(){
                      // Pretend the file exists. 
                      sut.$('localDirectoryExists').$args('/tmp/webroot/').$results(true);
                      sut.$('localDirectoryList').$args(
                          path="/tmp/webroot/",
                          recurse=true,
                          listInfo="array",
                          filter="*.md",
                          type="file").$results([
                              "/tmp/webroot/file.md"
                          ]);
  
                      sut.$('localFileRead').$args("/tmp/webroot/file.md").$results("content");
                          
                      var ret = sut.extension_not_allowed(
                          {
                              "type": "extension_not_allowed",
                              "path": "webroot/",
                              "value": "*.md",
                              "severity": 2,
                              "message": "Extension .md not allowed in webroot/",
                              "href": "https://google.com"
                          }
                      );
                      debug( ret );
                      expect( ret ).toBeArray();
                      expect( ret[1].uri ).toBe("file:///tmp/webroot/file.md");
                      expect( ret[1].message ).toBe("Extension .md not allowed in webroot/");
                      expect( ret[1].severity ).toBe(2);
                      expect( ret[1].keyExists("codeDescription") ).toBe(true);
                      expect( ret[1].codeDescription.keyExists("href")).toBe(true);
                      expect( ret[1].codeDescription.href).toBe("https://google.com");

                });
                it( "folder_not_allowed", function(){
                    var sut = new cfrules.CFRules(
                        rules: {
                            "workspace": [
                                {
                                    "type": "folder_not_allowed",
                                    "path": "webroot/",
                                    "value": "tests",
                                    "severity": 2,
                                    "message": "Folder tests not allowed in webroot/"
                                }
                            ]
                        }, 
                        rootPath: "/tmp"
                    );
                    prepareMock(sut);
                    makePublic(sut, "localDirectoryExists");
                    makePublic(sut, "localDirectoryList");
                    sut.$('localDirectoryExists').$args('/tmp/webroot/').$results(true);
                    sut.$('localDirectoryList').$args(
                        path="/tmp/webroot/",
                        recurse=true,
                        listInfo="array",
                        filter="tests",
                        type="dir").$results([
                            "/tmp/webroot/tests"
                        ]);

                    // sut.$('localFileRead').$args("/tmp/webroot/file.md").$results("content");
                        
                    var ret = sut.folder_not_allowed(
                        {
                            "type": "folder_not_allowed",
                            "path": "webroot/",
                            "value": "tests",
                            "severity": 2,
                            "message": "Folder [tests] not allowed in webroot/"
                        }
                    );
                    debug( ret );
                    expect( ret ).toBeArray();
                    expect( ret[1].uri ).toBe("file:///tmp/webroot/tests");
                    expect( ret[1].message ).toBe("Folder [tests] not allowed in webroot/");
                    expect( ret[1].severity ).toBe(2);
                    expect( ret[1].keyExists("codeDescription") ).toBe(false);

                    var ret = sut.folder_not_allowed(
                        {
                            "type": "folder_not_allowed",
                            "path": "webroot/",
                            "value": "tests",
                            "severity": 2,
                            "message": "Folder [tests] not allowed in webroot/", 
                            "href": "https://google.com"
                        }
                    );
                    debug( ret );
                    expect( ret ).toBeArray();
                    expect( ret[1].uri ).toBe("file:///tmp/webroot/tests");
                    expect( ret[1].message ).toBe("Folder [tests] not allowed in webroot/");
                    expect( ret[1].severity ).toBe(2);
                    expect( ret[1].keyExists("codeDescription") ).toBe(true);
                    expect( ret[1].codeDescription.keyExists("href")).toBe(true);
                    expect( ret[1].codeDescription.href).toBe("https://google.com");
                } );
            });

        } );
    }

}
