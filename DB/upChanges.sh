#!/bin/bash

absPath=$(pwd)

mkdir -p ~/bin/dbcli
cd ~/bin/dbcli
python3 -m venv "dbli_env"
source "dbli_env/bin/activate"
pip install neo4j
deactivate

cd $absPath
pref="#!"
top=$HOME/bin/dbcli/dbli_env/bin/python3
top=$(echo $pref$top)
echo "$top" > dbcli.py
cat dbcli_template.py >> dbcli.py
chmod +x dbcli.py
cp dbcli.py ~/bin/dbcli/dbcli
rm dbcli.py

line='export PATH="~/bin/dbcli:$PATH"'
file=~/.bashrc
if ! grep -qF "$line" "$file"; then
    echo "$line" >> "$file"
else
    echo "Line already exists in $file"
fi


source ~/.bashrc