component {


    function init(lspserver, logger){
        variables.lspserver = lspserver;
        variables.console = logger;
    
    }

    function setTrace(item){
        console.log("setTrace", item);
    }

    function cancelRequest(item){
        console.log("cancelRequest", item);
    }
    
}