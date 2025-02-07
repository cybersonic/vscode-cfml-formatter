/**
 * Component that Stores all the data
 **/
component accessors=true {
    property name="store" type="struct";
    property name="documents" type="struct";
    property name="messages" type="array";


    function init(){
        setStore({});
        setDocuments({});
        setMessages([]);
        return this;
    }

    // We should add all the things we store here, so for example, add messagae


    function addMessage( any id, any method, required string type, any message={}){
        getMessages().append(
            {
                "id": id?:nullValue(),
                "method": method?:nullValue(),
                "type": type,
                "message": message
            }
        )
    }
    function addItem(required string key, required any value){
       var store = getStore();
       store[key] = value;
    }

    function getItem(required string key){
        var store = getStore();
        return store[key];
    }
}