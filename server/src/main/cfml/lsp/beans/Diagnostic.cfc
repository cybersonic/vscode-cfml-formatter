component accessors="true" {
   /**
	 * The range at which the message applies.
	 */
	property name="range";

	/**
	 * The diagnostic's severity. To avoid interpretation mismatches when a
	 * server is used with different clients it is highly recommended that
	 * servers always provide a severity value. If omitted, it’s recommended
	 * for the client to interpret it as an Error severity.
	 */
	property name="severity" type="number";

	/**
	 * The diagnostic's code, which might appear in the user interface.
	 */
	property name="code" type="string";

	/**
	 * An optional property to describe the error code.
	 *
	 * @since 3.16.0
	 */
	property name="codeDescription" type="string";

	/**
	 * A human-readable string describing the source of this
	 * diagnostic, e.g. 'typescript' or 'super lint'.
	 */
	property name="source";

	/**
	 * The diagnostic's message.
	 */
	property name="message";

	/**
	 * Additional metadata about the diagnostic.
	 *
	 * @since 3.15.0
	 */
	property name="tags";

	/**
	 * An array of related diagnostic information, e.g. when symbol-names within
	 * a scope collide all definitions can be marked via this property.
	 */
	property name="relatedInformation";

	/**
	 * A data entry field that is preserved between a
	 * `textDocument/publishDiagnostics` notification and
	 * `textDocument/codeAction` request.
	 *
	 * @since 3.16.0
	 */
	property name="data";
}