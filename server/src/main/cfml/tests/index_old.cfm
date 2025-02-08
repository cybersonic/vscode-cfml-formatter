<cfscript>

  
  textDocument = new lsp.methods.textDocument({}, {});

  rootURI = "file:///Users/markdrew/Code/DistroKid/VSCode/lsp-example-workspace";

  root = textDocument.findConfigFile("file:///Users/markdrew/Code/DistroKid/VSCode/lsp-example-workspace/example_formatting_changed.cfm",rootURI);
  dump(var=root, label="From Root");
  childWithFormat = textDocument.findConfigFile("file:///Users/markdrew/Code/DistroKid/VSCode/lsp-example-workspace/subfolder/Child.cfc",rootURI);
  dump(var=childWithFormat, label="From Child with Format");
  childWithoutFormat = textDocument.findConfigFile("file:///Users/markdrew/Code/DistroKid/VSCode/lsp-example-workspace/noformat/NoFormatChild.cfc",rootURI);
  dump(var=childWithoutFormat, label="From Child without Format");
  

//   file:///Users/markdrew/Code/DistroKid/VSCode/lsp-example-workspace/example_formatting_changed.cfm

dump(server.documents);
dump(server);

</cfscript>