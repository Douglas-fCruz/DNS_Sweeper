#!/bin/bash

##### COLORS #####

RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
MAGENTA="\033[1;35m"
CYAN="\033[1;36m"
WHITE="\033[1;37m"
RESET="\033[0m"

#### UI #####

dns_sweeper="${CYAN}===================${RESET}${WHITE}DNS SWEEPER TOOL!${RESET}${CYAN}=====================${RESET}"

ipv4="${YELLOW}IPV4${RESET}${CYAN}=====${RESET}"
ipv6="${YELLOW}IPV6${RESET}${CYAN}=====${RESET}"
transferzone="${YELLOW}TRANSFERZONE${RESET}${CYAN}=====${RESET}"
nameserver="${YELLOW}NAME SERVER${RESET}${CYAN}=====${RESET}"
spf="${YELLOW}SENDER POLICY FRAMEWORK${RESET}${CYAN}=====${RESET}"
mx="${YELLOW}MAIL-SERVER${RESET}${CYAN}=====${RESET}"
cname="${YELLOW}CNAME${RESET}${CYAN}=====${RESET}"

bar="${CYAN}=========================================================${RESET}"

show_manual="
                ${WHITE}DNS SWEEPER MANUAL${RESET}
${bar}

${RED}Type of Service Options:${RESET}

${YELLOW}-h${RESET}, ${MAGENTA}--help${RESET}     ${BLUE}#${RESET} ${WHITE}Show manual;${RESET}
${YELLOW}-d${RESET}, ${MAGENTA}--default${RESET}  ${BLUE}#${RESET} ${WHITE}TYPE A & Quad-A (IPV4-IPV6);${RESET}
${YELLOW}-4${RESET}, ${MAGENTA}--ip4${RESET}      ${BLUE}#${RESET} ${WHITE}IPV4 Resolver;${RESET}
${YELLOW}-6${RESET}, ${MAGENTA}--ip6${RESET}      ${BLUE}#${RESET} ${WHITE}IPV6 Resolver;${RESET}
${YELLOW}-n${RESET}, ${MAGENTA}--ns${RESET}       ${BLUE}#${RESET} ${WHITE}Name Server Discovery;${RESET}
${YELLOW}-t${RESET}, ${MAGENTA}--transf${RESET}   ${BLUE}#${RESET} ${WHITE}Transfer Zone;${RESET}
${YELLOW}-s${RESET}, ${MAGENTA}--sender${RESET}   ${BLUE}#${RESET} ${WHITE}SPF Discovery;${RESET}
${YELLOW}-mx${RESET}, ${MAGENTA}--mail${RESET}    ${BLUE}#${RESET} ${WHITE}Mail Servers;${RESET}
${YELLOW}-c${RESET}, ${MAGENTA}--cname${RESET}    ${BLUE}#${RESET} ${WHITE}CNAME;${RESET}
${YELLOW}-w${RESET}, ${MAGENTA}--wordlist${RESET} ${BLUE}#${RESET} ${WHITE}Subdomain bruteforce;${RESET}

${bar}

${YELLOW}Example:${RESET}

${BLUE}./dns_sweeper.sh${RESET} ${YELLOW}-d${RESET} ${RED}example.com${RESET}

${WHITE}WORDLIST:${RESET}

${BLUE}./dns_sweeper.sh${RESET} ${YELLOW}-w subdomains.txt${RESET} ${RED}example.com${RESET}


${bar}
"

##### FLAGS #####

RUN_DEFAULT=false
RUN_IPV4=false
RUN_IPV6=false
RUN_NS=false
RUN_TRANSF=false
RUN_SENDER=false
RUN_ALL=false
RUN_MX=false
RUN_CNAME=false
WORDLIST=""

##### ARGUMENTS #####

while [[ $# -gt 0 ]]; do
        case "$1" in
                -d|--default) RUN_DEFAULT=true ;;
                -4|--ip4) RUN_IPV4=true ;;
                -6|--ip6) RUN_IPV6=true ;;
                -mx|--mail) RUN_MX=true ;;
               	-c|--cname) RUN_CNAME=true ;;
		-n|--ns) RUN_NS=true ;;
                -t|--transf) RUN_TRANSF=true ;;
                -s|--sender) RUN_SENDER=true ;;
                -a|--all) RUN_ALL=true ;;
                -w|--wordlist) WORDLIST="$2"; shift ;;
                -h|--help) printf "%b\n" "$show_manual"; exit 0 ;;
                *)
                        if [[ "$1" != -* ]]; then
                                domain="$1"
                        else
                                printf "${YELLOW}Invalid Option${RESET}\n"
                                printf "${RED}PARAMETER:${RESET} ${BLUE}'$1'${RESET} ${WHITE}DOES NOT EXIST!${RESET}\n"
                                printf "%b\n" "$show_manual"
                                exit 1
                        fi
                        ;;
        esac
        shift
done

##### VALIDATION #####

if [[ ! "$domain" =~ ^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        printf "${RED}Error:${RESET} ${BLUE}'$domain'${RESET} ${WHITE}INVALID DOMAIN!${RESET}\n"
        exit 1
fi

##### RESOLVE FUNCTIONS #####

resolve_ipv4() {
        target="$1"
        printf "%b\n" "$ipv4"
        result=$(host -t A "$target" 2>/dev/null | awk '/has address/ {print $NF}')
        [[ -z "$result" ]] && printf "${GREEN}%s${RESET} ${YELLOW}----->${RESET} ${WHITE}NOT FOUND${RESET}\n" "$target" || while read -r ip; do printf "${GREEN}%s${RESET} ${YELLOW}----->${RESET} ${WHITE}%s${RESET}\n" "$target" "$ip"; done <<< "$result"
        echo
}

resolve_ipv6() {
        target="$1"
        printf "%b\n" "$ipv6"
        result=$(host -t AAAA "$target" 2>/dev/null | awk '/IPv6/ {print $NF}')
        [[ -z "$result" ]] && printf "${GREEN}%s${RESET} ${YELLOW}----->${RESET} ${WHITE}NOT FOUND${RESET}\n" "$target" || while read -r ip; do printf "${GREEN}%s${RESET} ${YELLOW}----->${RESET} ${WHITE}%s${RESET}\n" "$target" "$ip"; done <<< "$result"
        echo
}

resolve_cname() {
        target="$1"
	printf "%b\n" "$cname"	

        result=$(host -t CNAME "$target" 2>/dev/null | awk '/alias for/ {print $NF}')

        if [[ -z "$result" ]]; then
                printf "${GREEN}%s${RESET} ${YELLOW}----->${RESET} ${WHITE}NOT FOUND${RESET}\n" "$target"
        else
                while read -r cname; do
                        printf "${GREEN}%s${RESET} ${YELLOW}----->${RESET} ${WHITE}%s${RESET}\n" "$target" "$cname"
                done <<< "$result"
        fi

        echo
}

resolve_ns() {
        target="$1"
        printf "%b\n" "$nameserver"
        result=$(host -t NS "$target" 2>/dev/null | awk '{print $NF}')
        [[ -z "$result" ]] && printf "${GREEN}%s${RESET} ${YELLOW}----->${RESET} ${WHITE}NOT FOUND${RESET}\n" "$target" || while read -r ns; do printf "${GREEN}%s${RESET} ${YELLOW}----->${RESET} ${WHITE}%s${RESET}\n" "$target" "$ns"; done <<< "$result"
        echo
}

resolve_mx() {
        target="$1"
        printf "%b\n" "$mx"
        result=$(host -t MX "$target" 2>/dev/null | awk '{print $NF}')
        [[ -z "$result" ]] && printf "${GREEN}%s${RESET} ${YELLOW}----->${RESET} ${WHITE}NOT FOUND${RESET}\n" "$target" || while read -r mxr; do printf "${GREEN}%s${RESET} ${YELLOW}----->${RESET} ${WHITE}%s${RESET}\n" "$target" "$mxr"; done <<< "$result"
        echo
}

resolve_spf() {
        target="$1"
        printf "%b\n" "$spf"
        result=$(host -t TXT "$target" 2>/dev/null | grep "v=spf" | awk -F'"' '{print $2}')
        [[ -z "$result" ]] && printf "${GREEN}%s${RESET} ${YELLOW}----->${RESET} ${WHITE}NOT FOUND${RESET}\n" "$target" || printf "${GREEN}%s${RESET} ${YELLOW}----->${RESET} ${WHITE}%s${RESET}\n" "$target" "$result"
        echo
}

##### WORDLIST #####

bruteforce_and_resolve() {
        printf "${CYAN}=====${RESET}${YELLOW}SUBDOMAIN ENUM${RESET}${CYAN}=====${RESET}\n"

        while read -r sub; do
                full_domain="${sub}.${domain}"

                if host "$full_domain" > /dev/null 2>&1; then

                        printf "\n${GREEN}FOUND:${RESET} ${WHITE}%s${RESET}\n" "$full_domain"
                        printf "%b\n" "$bar"

                        resolve_ipv4 "$full_domain"
                        resolve_ipv6 "$full_domain"
			resolve_cname "$full_domain"
                        resolve_ns "$full_domain"
                        resolve_mx "$full_domain"
                        resolve_spf "$full_domain"

                        printf "%b\n" "$bar"
                fi

        done < "$WORDLIST"

        print_footer
}

##### ORIGINAL MODES #####

run_default() { printf "%b\n\n" "$dns_sweeper"; resolve_ipv4 "$domain"; resolve_ipv6 "$domain"; printf "%b\n" "$bar"; }
run_ipv4() { printf "%b\n\n" "$dns_sweeper"; resolve_ipv4 "$domain"; printf "%b\n" "$bar"; }
run_ipv6() { printf "%b\n\n" "$dns_sweeper"; resolve_ipv6 "$domain"; printf "%b\n" "$bar"; }
run_ns() { printf "%b\n\n" "$dns_sweeper"; resolve_ns "$domain"; printf "%b\n" "$bar"; }
run_mx() { printf "%b\n\n" "$dns_sweeper"; resolve_mx "$domain"; printf "%b\n" "$bar"; }
run_sender() { printf "%b\n\n" "$dns_sweeper"; resolve_spf "$domain"; printf "%b\n" "$bar"; }
run_cname() { printf "%b\n\n" "$dns_sweeper"; resolve_cname "$domain"; printf "%b\n" "$bar"; }

##### EXECUTION #####

[ "$RUN_DEFAULT" = true ] && run_default
[ "$RUN_IPV4" = true ] && run_ipv4
[ "$RUN_IPV6" = true ] && run_ipv6
[ "$RUN_NS" = true ] && run_ns
[ "$RUN_MX" = true ] && run_mx
[ "$RUN_SENDER" = true ] && run_sender
[ "$RUN_CNAME" = true ] && run_cname

if [[ -n "$WORDLIST" ]]; then
        bruteforce_and_resolve
fi
