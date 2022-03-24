DEFAULT_POST=8080
if [[ $# -eq 0 ]] ; then
    port=$DEFAULT_POST
else
    port=$1
fi

start_time=$(date +%s.%3N)

echo "Wait until application successfully replies to the first request on port $port ..."

while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' http://localhost:$port/owners/find)" != "200" ]]; 
    do sleep .00001; 
done

end_time=$(date +%s.%3N)

elapsed=$(echo "scale=3; $end_time - $start_time" | bc)
echo "Elapsed time: "$elapsed" ms"
