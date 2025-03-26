component accessors=true {

    variables.initilized = false;

    property name="beanFactory";
    property name="lspEndpoint";
    property name="Console";
    property name="pendingMessages" type="structure";

    function initialize(lspEndpoint) {
        var beanFactory = new framework.ioc('/lsp');
        beanFactory.declare('LSPServer').asValue(this);
        beanFactory.declare('$').instanceOf('lsp.methods.Util');
        


        var cfformatPath = expandPath('/cfformat/');
         fileSetAccessMode(cfformatPath & 'bin/cftokens_osx_x86_64', '777');
         fileSetAccessMode(cfformatPath & 'bin/cftokens_osx_arm', '777');
         fileSetAccessMode(cfformatPath & 'bin/cftokens_osx', '777');
         fileSetAccessMode(cfformatPath & 'bin/cftokens_linux_musl', '777');
         fileSetAccessMode(cfformatPath & 'bin/cftokens_linux', '777');
         fileSetAccessMode(cfformatPath & 'bin/cftokens.exe', '777');
         fileSetAccessMode(cfformatPath & 'bin/cftokens', '777');

        
        // fileSetAccessMode(cfformatPath & 'bin/cftokens_osx', '777');
        // fileSetAccessMode(cfformatPath & 'bin/cftokens_linux', '777');
        // fileSetAccessMode(cfformatPath & 'bin/cftokens_linux_musl', '777');
        var cfformat = new cfformat.models.CFFormat(cfformatPath & 'bin/', cfformatPath);
        beanfactory.declare('CFFormat').asValue(cfformat);
        setBeanFactory(beanFactory);
        variables.console = variables.beanFactory.getBean('Console');
        setConsole(variables.console);


        // Ask for the configuration from the client
        // param name="variables.pendingMesssages" type="struct" default={};

        // var config = {
        //     'jsonrpc': '2.0',
        //     'id': createUUID(),
        //     'method': 'workspace/configuration',
        //     'params': {
        //         "items": [
        //             {
        //                 "section": "cfml-formatter"
        //             }
        //         ]
        //     }
        // };
        // variables.pendingMessages[config.id] = config;
        // lspEndpoint.sendMessageToClient(config);
        // Store a log of pending messages to be fulfilled. 
        console.log('- Initializing LSP Server');

        variables.initilized = true;



        console.log('- Finished Initializing LSP Server');
        return this;
    }

    function refresh() {
        initialize();
    }

    public any function execute(required struct jsonMessage, any lspEndpoint) {
        // setup our objects if they are not setup
       
        if (!variables.initilized OR isNull(getBeanFactory())) {
            initialize(lspEndpoint);

            if (isNull(getBeanFactory())) {
                console.log('Bean Factory is null');
                throw('Bean Factory is null');
            }
        }
        //if there is no response. and we have a result key, it's a response. Check in the sent messages by id 
        

        setLspEndpoint(lspEndpoint)
        // Set the endpoint
        var ioc = getBeanFactory();
        ioc.declare('LSPEndpoint').asValue(lspEndpoint);

        var nullResult = {'jsonrpc': '2.0', 'result': nullValue()}

        var messageStore = ioc.getBean('MessageStore');
        // var documentStore = ioc.getBean("TextDocumentStore");

        // console.log("execute", jsonMessage);
        // console.log("Request[#jsonMessage.method#]: ", jsonMessage);
        // Log the incoming message
        messageStore.addMessage(
            id: jsonMessage.id ?: nullValue(),
            method: jsonMessage.method ?: 'unknown',
            type: 'request',
            message: jsonMessage
        );

        var message = jsonMessage;

        if (!message.keyExists('method')) {
            // We dont know what to do so we shouldnt do anything
            // return "{}";
            console.log('No method', jsonMessage);

            messageStore.addMessage(
                id: jsonMessage.id ?: nullValue(),
                method: 'err:no_method',
                type: 'response',
                message: nullResult
            );

            return nullResult;
        }

        // TODO: do a check that we are setup by getting the config (if it's not an init message) and call tghe client for an init.

        var methodArr = listToArray(message.method, '/');
        var object = 'lifecycle';
        var method = '';
        if (methodArr.len() EQ 1) {
            method = methodArr[1];
        }
        if (methodArr.len() EQ 2) {
            object = methodArr[1];
            method = methodArr[2];
        }

        var resp = {};

        if (!ioc.containsBean(object)) {
            // Dont know what to do
            messageStore.addMessage(
                id: jsonMessage.id ?: nullValue(),
                method: 'err:no_object',
                type: 'response',
                message: nullResult
            );
            return nullResult;
        }

        var service = ioc.getBean(object);
        resp = service[method](message);


        // If it is not a notification, we need to return a response
        if (message.keyExists('id') && !isNull(resp)) {
            resp.jsonrpc = '2.0';
            resp.id = message.id;
            // Find out which Object to use
            // console.log("Response[#jsonMessage.method#]: ", resp);
            messageStore.addMessage(
                id: jsonMessage.id ?: nullValue(),
                method: jsonMessage.method ?: 'unknown',
                type: 'response',
                message: resp
            );



            return serializeJSON(resp);
        }



        // return nullResult;
    }

}