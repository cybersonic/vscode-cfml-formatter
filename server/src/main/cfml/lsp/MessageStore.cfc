component accessors="true" {
    property name="messages";
    property name="beanFactory";
    function init(){
            setMessages([]);
            return this;
    }

    function addMessage( any id, any method, required string type, any message={}){
        getMessages().append(
            {
                "id": arguments.id?:nullValue(),
                "method": arguments.method?:nullValue(),
                "type": arguments.type,
                "message": arguments.message
            }
        );
    }
}