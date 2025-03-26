
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>LLSP - Send Message</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
</head>
<body>

   
    <cfscript>
        param name="form.method" type="string" default="";
        param name="form.message" type="string" default="";
        param name="form.section" type="string" default="";

        methods = [
            "window/showMessage",
            "window/showMessageRequest",
            "window/logMessage",
            "window.showDocument",
            "workspace/configuration"
            
        ];

    </cfscript>
    <div class="container">
    <cfoutput>
        <form method="post" action="/message.cfm" id="form">
            
            <div class="mb-3">
                <label for="method" class="form-label">Method</label>
                <select name="method"id="method">
                    <cfloop array="#methods#" item="method">
                        <option value="#method#" #form.method EQ method ? "selected" : ""#>#method#</option>
                    </cfloop>
                </select>
            </div>
            <div class="mb-3">
                <label for="message" class="form-label">Message</label>
                <textarea class="form-control" id="message" name="message" rows="3">#form.message#</textarea>
            </div>
            <div class="mb-3">
                <label for="type" class="form-label">Type</label>
                <select name="type">
                    <option value="1">Error</option>
                    <option value="2">Warning</option>
                    <option value="3">Info</option>
                    <option value="4">Log</option>
                </select>
            </div>
            <div class="mb-3">
                <label for="section" class="form-label">section</label>
                <textarea class="form-control" id="section" name="section" rows="3">#form.section#</textarea>
            </div>

            <button type="submit" class="btn btn-primary">Send</button>

        </form>
    </cfoutput>
    </div>
    <cfscript>
        instance=createObject("java","lucee.runtime.lsp.LSPEndpointFactory").getExistingInstance();
        if(Len(form.method)){
            clientMessage = {
                "jsonrpc": "2.0",
                "method": form.method,
                "params": {}
            }

            if(form.method EQ "workspace/configuration"){
                clientMessage.params = {
                    "items": [
                        {
                            "section": "cfml-formatter"
                        }
                    ]
                }
            }
            else {
                clientMessage.params = {
                    "type": 3,
                    "message": form.message
                }
            }
            dump(var=clientMessage, label="Original Client Message");
            echo("<code>#serializeJSON(clientmessage)#</code>")
            dump(instance.sendMessageToClient(clientMessage, false));
            dump(var=clientMessage, label="AfterSend  Client Message");
        }
    </cfscript>
    <script>
        var configs = {
            "window/showMessage": {
                "items": "message,type"
            },
            "window/showMessageRequest": {
                "items": "message"
            },
            "window/logMessage": {
                "items": "message"
            },
            "window.showDocument": {
                "items": "uri"
            },
            "workspace/configuration": {
                "items": "uri"
            }
        }

        document.getElementById("method").addEventListener("change", updateConfig);
        updateConfig();

        function updateConfig(){
            var method = document.getElementById("method").value;
            var config = configs[method];
            var items = config.items.split(",");
            var form = document.getElementById("form");
            var inputs = form.querySelectorAll("input, textarea, select");
            inputs.forEach(function(input){
                if(input.name == "method") return;
                input.disabled = true;
            });
            items.forEach(function(item){
                var input = form.querySelector("[name='"+item+"']");
                if(input){
                    input.disabled = false;
                }
            });
        }

        
    </script>



<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>
</body>
</html>