#! /usr/bin/bash

{
cat <<'EOF'
#! /usr/bin/bash

# Step 1: Declare the variables to be used
declare -A map_long_to_short
declare -A map_short_type
declare -A map_runtime
declare -i ARGC

error_log() {
    printf "\e[91m[Error]: $@\n\e[97m" >&2
    exit 1
}

print_array() {
    declare -nl pointer="$1"
    local length="${#pointer[@]}"
    local i=0
    printf "{\n"
    for k in "${!pointer[@]}"; do
        if (( $i == $length - 1 )); then
            printf "\t\"${k}\" : \"${pointer[${k}]}\"\n"
            break
        fi
        printf "\t\"${k}\" : \"${pointer[${k}]}\",\n"
        i=$(( i + 1 ))
    done
    printf "}\n"
}
EOF

printf "\n"

printf "instantiate_mappings() {\n\n"
OLDIFS="$IFS"
IFS=":"
for x in "$@"; do
    read long short type <<< $x
    if [[ ! -z "${long}" ]]; then
        printf "\tmap_long_to_short[\"${long}\"]=\"${short}\"\n"
    fi
    printf "\tmap_short_type[\"${short}\"]=\"${type}\"\n"
    if [[ "${type}" == "k" ]]; then
        printf "\tmap_runtime[\"${short}\"]=false\n"
    fi
    printf "\n"
done
printf "}\n\n"

cat <<'EOF'
parse_command_line() {
    instantiate_mappings
    prev_value=""
    current_word_type="k"
    ARGC=0
    for word in "$@"; do
        if [[ "${word}" == "--" ]]; then
            ARGC=$(( ARGC + 1 ))
            break
        fi 
        if [[ "${current_word_type}" == "k" ]]; then
            case "${word}" in
                --*)
                    word=${word##--}
                    [[ ! -z "${map_long_to_short[${word}]}" ]] || error_log "option --${word} does not exist"
                    short_code="${map_long_to_short[${word}]}"
                    short_code_type="${map_short_type[${short_code}]}"
                    if [[ "${short_code_type}" == "k" ]]; then
                        map_runtime["${short_code}"]=true
                        prev_value=""
                        current_word_type="k"
                        ARGC=$(( ARGC + 1 ))
                        continue
                    fi
                    prev_value="${short_code}"
                    current_word_type="${short_code_type}"
                    ARGC=$(( ARGC + 1 ))
                ;;
                -*)
                    word=${word##-}
                    [[ ! -z "${map_short_type[${word}]}" ]] || error_log "option -${word} does not exist"
                    short_code_type="${map_short_type[${word}]}"
                    if [[ "${short_code_type}" == "k" ]]; then
                        map_runtime["${word}"]=true
                        prev_value=""
                        current_word_type="k"
                        ARGC=$(( ARGC + 1 ))
                        continue
                    fi
                    prev_value="${word}"
                    current_word_type="${short_code_type}"
                    ARGC=$(( ARGC + 1 ))
                ;;
                *)
                    error_log "${word} does not start with '--' or '-' and is not recognised as an option."
                ;;
            esac
        elif [[ "${current_word_type}" == "v" ]]; then
            case "${word}" in
                -*)
                    error_log "${word} start with '-' which is not allowed for values."
                ;;
                *)
                    map_runtime["${prev_value}"]="${word}"
                    prev_value=""
                    current_word_type="k"
                    ARGC=$(( ARGC + 1 ))
                ;;
            esac
        fi
    done
}

parse_command_line "$@"
EOF
} > parse-command-line.sh


cat <<'EOF'
########## EXAMPLE (put this in a main.sh) ##########
#! /usr/bin/bash

. ./parse-command-line.sh "$@"
shift $ARGC

# printing out variables which are defined in parse-command-line.sh
echo "ARGC: $ARGC"
print_array "map_long_to_short"
print_array "map_short_type"
print_array "map_runtime"
echo $1
EOF
