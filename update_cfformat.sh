#!/bin/bash
# git subtree pull --prefix=server/src/main/cfml/cfformat https://github.com/jcberquist/commandbox-cfformat.git master --squash

# cd server/src/main/cfml/cfformat
# box install
# The command below does not work, so I have to run it manually
# box task run build cftokens
# cd ../../../../../
# pwd
curl -s -o server/src/main/cfml/cfformat/bin/v0.16.12/cftokens.exe  https://github.com/jcberquist/cftokens/releases/download/v0.16.12/cftokens.exe 
curl -s -o server/src/main/cfml/cfformat/bin/v0.16.12/cftokens_linux https://github.com/jcberquist/cftokens/releases/download/v0.16.12/cftokens_linux
curl -s -o server/src/main/cfml/cfformat/bin/v0.16.12/cftokens_linux_musl https://github.com/jcberquist/cftokens/releases/download/v0.16.12/cftokens_linux_musl
curl -s -o server/src/main/cfml/cfformat/bin/v0.16.12/cftokens_osx https://github.com/jcberquist/cftokens/releases/download/v0.16.12/cftokens_osx
curl -s -o server/src/main/cfml/cfformat/bin/v0.16.12/cftokens_osx_arm https://github.com/jcberquist/cftokens/releases/download/v0.16.12/cftokens_osx_arm
curl -s -o server/src/main/cfml/cfformat/bin/v0.16.12/cftokens_osx_x86_64 https://github.com/jcberquist/cftokens/releases/download/v0.16.12/cftokens_osx_x86_64
