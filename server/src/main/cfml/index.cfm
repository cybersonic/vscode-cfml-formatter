<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>LLSP - Lucee Language Server</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
</head>
<body>
    <cfscript>
        param name="FORM.ignorefilter" default="";
        param name="FORM.msgCount" default=50;
        cs=getPageContext().getConfig().getConfigServerImpl();
        instance=createObject("java","lucee.runtime.lsp.LSPEndpointFactory").getExistingInstance();
        comp = instance.getComponent();
        comp_mt = getMetadata(comp);
        bf = comp.getBeanFactory();
        docStore = bf.getBean("TextDocumentStore");
        configStore = bf.getBean("ConfigStore");
        messageStore = bf.getBean("MessageStore");
        documents = docStore.getDocuments();

        // dump(instance);
        
        // dump(instance.getComponent().getObjects().lifecycle.getConfig());
        message = {
            "jsonrpc": "2.0",
            "method": "workspace/configuration",
            "id": "666",
            "params": {
                "items": [
                    {
                        "section": "cfml-formatter"
                    }
                ]
            }
        }
        dump(instance.sendMessageToClient(message) );
        
        // dump(instance.processMessage('{"jsonrpc":"2.0","method":"initialized","params":{}}'));

        config = server.objs.lifecycle.getConfig() ?: {};
        rootURI = config.rootUri ?: "";

        param name="url.reload" default=false;
        if(url.reload){
            comp.refresh();
        }

        function relativePath(path){
            return path.replace(rootURI, "");
        }

        
        function objToList(obj, trimLen=0){
            var output = "<ul>";
            for(var key in obj){
                outSTring = obj[key];
                if(trimLen){
                    outSTring = left(outSTring, trimLen) & "...";
                }

                output &= "<li><strong>#relativePath(key)#</strong>:
                    <div class='small' id='file_#hash(key)#'>
                        <code><pre>#obj[key]#</pre></code>
                    </div>
                    </li>";
            }

            output &= "</ul>";
            // var list=[];
            // for(var key in obj){
            //     list.append({key=key,value=obj[key]});
            // }
            // return list;
            return output;
        }
    </cfscript>

    
    <div class="container-fluid">        
        <cfoutput>
        <h1>Lucee Language Server Status</h1>
            <ul class="nav">
                <li class="nav-item">
                  <a class="nav-link active" aria-current="page" href="/">Home</a>
                </li>
                <li class="nav-item">
                  <a class="nav-link" href="/tests/">Test Suite</a>
                </li>
              </ul>
        <h2>Settings</h2>
        <ul>
            <li><strong>Listener Instance</strong>: <code>#comp_mt.fullname#</code></li>
            <cfloop collection="#server.system.properties#" item="key">
                <cfif !key.startsWith("lucee.")>
                    <cfcontinue>
                </cfif>
            <li><strong>#key#</strong>: <code>#server.system.properties[key]#</code></li>
            </cfloop>

        </ul>

        <div class="row">
            <div class="col-md-6">
                <h3>Message Log</h3>


                <form  action="index.cfm" method="post">
                    <input type="text" class="form-control" placeholder="Ignore" id="ignoreFilter" value="#FORM.ignorefilter#" name="ignorefilter">
                    <input type="number" class="form-control" value="#FORM.msgCount#" name="msgCount">
                    <button class="btn btn-primary">Filter</button>
                </form>
                    
                <cfset unfiltered = messageStore.getMessages()>

               <cfset filtered = unfiltered.filter(function(item){
                    var method = item.message.method ?: "";
                    var respmethod = item.method ?: "";
                    return NOT (listFindNoCase(FORM.ignorefilter, Trim(method)) OR listFindNoCase(FORM.ignorefilter, Trim(respmethod)) );
                })>

                <!--- <cfdump var="#filtered.Len()#" label="Filtered">
                <cfdump var="#unfiltered.Len()#" label="All"> --->
                <cfset msgCount = FORM.msgCount>
                <cfset from=filtered.len()>
                <cfset to=from LT msgCount ?  1 : filtered.len() - msgCount>
                <cfset to= to LT 1 ? 1 : to>
                <table class="table table-sm">
                    <thead>
                        <tr>
                            <td colspan="6">#msgCount# out of #from#</td>
                        </tr>
                        <tr>
                            <th></th>
                            <th></th>
                            <th>id</th>
                            <th>method</th>
                            <th>type</th>
                            <th>nessage</th>
                        </tr>
                    </thead>
                    <tbody>
                        <!--- <cfdump var="#[from,to]#"> --->
                       
                        <cfloop from="#from#" to="#to#" index="idx" step="-1">
                            
                            <tr>
                                <cfif filtered[idx].type EQ "request">
                                    <td><i class="bi bi-box-arrow-down"></i></td>
                                <cfelseif filtered[idx].type EQ "response">
                                    <td><i class="bi bi-box-arrow-up"></i></td>
                                <cfelse>
                                    <td>?</td>
                                </cfif>

                                
                                <td>#idx#</td>
                                <td>#filtered[idx].id?:"-"#</td>
                                <td>#filtered[idx].method?:"-"#</td>
                                <td>#filtered[idx].type#</td>

                                <td>
                                    <cfif listFindNoCase("textDocument/didOpen,textDocument/didSave,textDocument/didClose,textDocument/didChange",  #filtered[idx].method#)>
                                        <i class="bi bi-file-code"></i>#relativePath(filtered[idx].message.params.textDocument.uri)#
                                    </cfif>
                                    
                                    <!--- <cfif filtered[idx].method EQ "textDocument/rangeFormatting">
                                        <cfscript>
                                            rangeFormat = server.objs.textDocument.rangeFormatting({
                                                "jsonrpc": "2.0",
                                                "method": "textDocument/rangeFormatting",
                                                "id": 1,
                                                "params": {
                                                    "textDocument": {
                                                        "uri": messages[idx].message.params.textDocument.uri
                                                    },
                                                    "range": {
                                                        "start": {
                                                            "line": messages[idx].message.params.range.start.line,
                                                            "character": messages[idx].message.params.range.start.character
                                                        },
                                                        "end": {
                                                            "line": messages[idx].message.params.range.end.line,
                                                            "character": messages[idx].message.params.range.end.character
                                                        }
                                                    },
                                                    "options": {
                                                        "tabSize": 4,
                                                        "insertSpaces": true
                                                    }
                                                }
                                            });

                                        </cfscript>
                                        <cfdump var="#rangeFormat#">
                                    REANGE FORMATTING!
                                    </cfif> --->
                                    
                                    <button class="btn btn-primary" data-detail="#idx#"><i class="bi bi-arrow-down-circle-fill"></i></button>
                                    <div id="detail-#idx#" style="display:none;">
                                        <cfdump var="#filtered[idx].message#">

                                        
                                    </div>
                                
                                </td>
                                <!--- <td>#messages[idx].message#</td> --->
                            </tr>
                        </cfloop>
                    </tbody>
                </table>
                <!--- <cfdump var="#server.store.getMessages()#"> --->
            </div>
            <div class="col-md-6">
                <h3>Documents</h3>

                <cfoutput>

                
                <ul>
                    <cfloop collection="#documents#" item="key">
                        <cfset docHash = hash(key)>
                        <li><i class="bi bi-file-code"></i><strong>#relativePath(key)#</strong> 
                            
                            <button class="btn btn-primary btn-sm" data-detail="#docHash#"><i class="bi bi-arrow-down-circle-fill"></i></button>: 
                            <div class='small' id='detail-#docHash#' style="display:none;">
                                <code><pre>#documents[key].getText()#</pre></code>
                            </div>
                        </li>
                    </cfloop>
                </ul>
                <!--- <h3>Documents Parsed</h3>
                <ul>
                    <cfloop collection="#server.documents_parsed#" item="key">
                        <cfset docHash = hash(key)>
                        <li><i class="bi bi-file-code"></i><strong><a href="/view/parsed/?document=#key#">#relativePath(key)#</a></strong> #StructKeyList(server.documents_parsed[key])#
                        </li>
                    </cfloop>
                </ul> --->
                <!--- <h3>Documents Tokenized</h3>
                <ul>
                    <cfloop collection="#server.documents_tokenized#" item="key">
                        <cfset docHash = hash(key)>
                        <li><i class="bi bi-file-code"></i><strong><a href="/view/parsed/?document=#key#">#relativePath(key)#</a></strong> #StructKeyList(server.documents_tokenized[key])#
                        </li>
                    </cfloop>
                </ul> --->


                    
                </cfoutput>
                <!--- <cfdump var="#server.documents?:{}#"> --->
            </div>
            
        </div>

        <hr>
        
        <!--- <cfdump var="#comp.getLspEndpoint()#"> --->
        
       
        </cfoutput>
    </div>
    <div class="row">
        <div class="col-md-6">
            <h2>Client Config</h2>
            <cfdump var="#configStore.getConfig()#" expand="false">
        </div>
    </div>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            var buttons = document.querySelectorAll('button[data-detail]');
            buttons.forEach(function(button){
                button.addEventListener('click', function(){
                    var detail = document.getElementById('detail-' + button.dataset.detail);
                    if(detail.style.display == 'none'){
                        detail.style.display = 'block';
                    } else {
                        detail.style.display = 'none';
                    }

                    
                    if(detail.style.display == 'block'){
                        button.innerHTML = '<i class="bi bi-arrow-up-circle-fill"></i>';
                    } else {
                        button.innerHTML = '<i class="bi bi-arrow-down-circle-fill"></i>';
                    }
                });
            });
        });
    </script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>
  </body>
</html>
