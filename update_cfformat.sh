#!/bin/bash
git subtree pull --prefix=server/src/main/cfml/cfformat https://github.com/jcberquist/commandbox-cfformat.git master --squash

cd server/src/main/cfml/cfformat
box install
box task run build cftokens