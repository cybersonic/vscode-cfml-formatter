/**
 * Copyright Since 2005 Ortus Solutions, Corp
 * www.ortussolutions.com
 * *************************************************************************************
 */
component {

	this.name              = "A TestBox Runner Suite";
	// any other application.cfc stuff goes below:
	this.sessionManagement = true;

	// any mappings go here, we create one that points to the root called test.
	this.mappings[ "/tests" ] = getDirectoryFromPath( getCurrentTemplatePath() );
	// Turn on/off remote cfc content whitespace
	this.suppressRemoteComponentContent = false;

	// any orm definitions go here.

	// request start
	public boolean function onRequestStart( String targetPage ){
		return true;
	}

}
