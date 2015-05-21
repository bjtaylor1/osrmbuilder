

if [ -n $(ps -ef | grep $1 | grep -v grep) ]; then
echo "$1 running!"
else
echo "$1 not running!"
fi

