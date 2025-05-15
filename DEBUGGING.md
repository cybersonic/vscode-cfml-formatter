# How to debug the extension

This document describes how to debug the extension in different environments.
It is recommended to use the latest version of CFML-Formatter extension, you can get the version from the extension panel or from the [marketplace](https://marketplace.visualstudio.com/items?itemName=markdrew.cfml-formatter) or via the VSIX file provided.

## Installlation

You can install the extension from the marketplace:

OR you can install the vsix file by clicking on the extension icon in the left panel, then click on the three dots in the top right corner and select "Install from VSIX".

## Debugging in VSCode

Once you have the extension installed, and if you open a CFML file you should see a notification saying "Starting the CFML Formatter Server". This will take a few seconds.

Once the server is started the notification will go away.

You can now open the command palette (Ctrl+Shift+P) and type "Format Document" to format the document. You can also use the shortcut Shift+Opt+F to format the document.

## Viewing the logs

You can view the logs by opening the output panel (Shift+Cmd+U) and selecting "CFML Formatter" from the dropdown. This will show you the logs for the extension.

There is another log called "CFML Formatter Server" which is the log for the server. This will show you the logs for the server which will show which files are being formatted and any errors that occur.

## Debugging the server

You can debug the server by opening the command palette (Ctrl+Shift+P) and typing "CFML Formatter: Open Server URL".

This will open the server URL in your browser. This shows the message stream and which documents are open.

## Known issues

- The extension might not work on Windows. I have made a number of assumptions to get it working, including installing cfformat and cftokens.
