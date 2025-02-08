component accessors="true" {
   /**
	 * The request id.
	 */
	property name="id";

	/**
	 * The method to be invoked.
	 */
	property name="method" type="string";

	/**
	 * The method's params.
	 */
	property name="params";
	
    /**
	 * The type of message request | repsonse | notification
	 */
	property name="type";

}