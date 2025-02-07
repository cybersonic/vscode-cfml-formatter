component {

    variables.initilized = false;


    

    function initialize(){
        getConsole();
        console.log("- Initializing LSP Server");
        getStore(); //Unused, I think we are storing everything in the server scope for the moment

        
        

        variables.objs = {
            "lifecycle": new methods.Lifecycle(this, variables.console),
            "textDocument": new methods.textDocument(this, variables.console),
            "$": new methods.Util(this, variables.console),
            "workspace": new methods.Workspace(this, variables.console),

        }
        server.objs = variables.objs;

        variables.initilized = true;

        console.log("- Finished Initializing LSP Server");
        return this; 
    }

    function getStore(){
        if(isNull(server.store)){
            server.store = new Store();
        }
        return server.store;
    }

    function getConsole(){
        if(isNull(variables.console)){
            variables.console = new Console(listToArray( "Did Close"));
        }
        return variables.console;
    }

    function refresh(){
        initialize();
    }

    function getLspEndpoint(){
        return variables.lspEndpoint;
    }

    // shortcut to the Lifecycle config
    function getConfig(){
        return variables.objs.lifecycle.getConfig();
    }

    function getObjects(){
        return variables.objs;
    }

    public any function execute(required struct jsonMessage, any lspEndpoint) {
        // setup our objects if they are not setup
        variables.lspEndpoint = lspEndpoint;
        
        var nullResult = {
            "jsonrpc" : "2.0",
            "result": nullValue()
        }

        if(!variables.initilized){
            initialize();
        }
        
        // console.log("execute", jsonMessage);
        // console.log("Request[#jsonMessage.method#]: ", jsonMessage);
        // Log the incoming message
        getStore().addMessage(jsonMessage.id ?: nullValue(), jsonMessage.method ?: "unknown", "request", jsonMessage);
        
        var message = jsonMessage;

        if(!message.keyExists("method")){
            // We dont know what to do so we shouldnt do anything
            // return "{}";
            getStore().addMessage(jsonMessage.id ?: nullValue(), "err:no_method", "response", nullResult);
            return nullResult;
        }

        // TODO: do a check that we are setup by getting the config (if it's not an init message) and call tghe client for an init. 

        var methodArr = listToArray(message.method, "/");
        var object = "lifecycle";
        var method = "";
        if(methodArr.len() EQ 1){
            method = methodArr[1];
        }
        if( methodArr.len() EQ 2){
            object = methodArr[1];
            method = methodArr[2];
        }

      

        if( !variables.objs.keyExists(object) ){
            // Dont know what to do
            getStore().addMessage(jsonMessage.id ?: nullValue(), "err:no_object", "response", nullResult);
            // return nullResult;
          
        }

        var resp = {};
        if(object == "textDocument"){
            var textDocument =  new methods.textDocument(this, variables.console);
            resp = textDocument[method](message);
            
        }
        else {
            resp = variables.objs[object][method](message);

        }
        // console.log("Object: ",  object, "Method: ",  method);


        // if(isNull(resp)){
        //     getStore().addMessage(jsonMessage.id ?: nullValue(), "err:null_response", "response", nullResult);
        //     // return;
        // }

        
        //  the adding of the message id and rpc

        
        
        // If it is not a notification, we need to return a response
        if(message.keyExists("id") && !isNull(resp)){
            resp.jsonrpc = "2.0";
            resp.id = message.id;
            // Find out which Object to use
            // console.log("Response[#jsonMessage.method#]: ", resp);

            getStore().addMessage(message.id, jsonMessage.method, "response", resp);


            return serializeJSON( resp );
        }


       
        // return nullResult;
     

    }


}