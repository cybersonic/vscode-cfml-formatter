component accessors="true" {
    
    this.uuid = createUUID();

    function init(required Singleton singleton){
        this.singleton = arguments.singleton;
        return this;
    }

}