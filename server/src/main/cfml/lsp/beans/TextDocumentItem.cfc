component accessors=true {
   /**
	 * The text document's URI.
	 */
	property name="uri" type="string";

	/**
	 * The text document's language identifier.
	 */
	property name="languageId" type="string";

	/**
	 * The version number of this document (it will increase after each
	 * change, including undo/redo).
	 */
	property name="version" type="numeric";

	/**
	 * The content of the opened text document.
	 */
	property name="text" type="string";


	/**
	 * The tokens of the opened text document.
	 */
	property name="tokens" type="array";

	/**
	 * The parsed version of the document.
	 */

	property name="parsed" type="struct";


	public string function _toString(){
		return getText();
	}
	public string function toString(){
		return getText();
	}

}