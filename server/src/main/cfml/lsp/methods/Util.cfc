component accessors="true" {

    property name="LSPServer";
    property name="Console";


    function init(){
        return this;
    }

    function setTrace(item){
        console.log("setTrace", item);
    }

    function cancelRequest(item){
        console.log("cancelRequest", item);
    }
    
}