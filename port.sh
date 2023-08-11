#!/bin/bash

getOpenPort() {
    minPort=50000
    maxPort=59999

    # Loop until an odd number is found
    while true; do
        openPort=$(curl -s "https://${PARSL_CLIENT_HOST}/api/v2/usercontainer/getSingleOpenPort?minPort=${minPort}&maxPort=${maxPort}&key=${PW_API_KEY}")
        # Check if the number is odd
        if [[ $(($openPort % 2)) -eq 1 ]]; then
            break
        fi
    done
    # Check if openPort variable is a port
    if ! [[ ${openPort} =~ ^[0-9]+$ ]] ; then
        qty=1
        count=0
        for i in $(seq $minPort $maxPort | shuf); do
            out=$(netstat -aln | grep LISTEN | grep $i)
            if [[ "$out" == "" ]] && [[ $(($i % 2)) -eq 1 ]]; then
                    openPort=$(echo $i)
                    (( ++ count ))
            fi
            if [[ "$count" == "$qty" ]];then
                break
            fi
        done
    fi
}

# Gets an available port
getOpenPort

if [[ "$openPort" == "" ]]; then
    echo "ERROR - cannot find open port..."
    exit 1
fi

# Create kill script:
echo "kill \$(ps -x | grep streamlit | grep ${openPort} | awk '{print \$1}')" > kill.sh

# Create service.html
cp service.html.template service.html
sed -i "s|__PORT__|${openPort}|g"  service.html
# Create service.json
cp service.json.template service.json
sed -i "s|__PORT__|${openPort}|g"  service.json

