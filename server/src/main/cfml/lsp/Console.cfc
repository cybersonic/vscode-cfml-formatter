component {
    function init(array excludes=[]){

        variables.excludes = arguments.excludes;
    }
        
    function log(){

        var firstArg = arguments[1] ?: "";

        if(arrayContains(variables.excludes, firstArg)){
            return;
        }
        


        for(var item in arguments){
            systemOutput(" ",false, false);
            var logItem = arguments[item];
            if(!isSimpleValue(logItem)){
                logItem = serializeJson(logItem);
            }
            systemOutput(logItem,Len(arguments) EQ item, false);
        }
    }
}