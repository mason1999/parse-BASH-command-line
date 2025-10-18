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

instantiate_mappings() {

	map_long_to_short["aye"]="a"
	map_short_type["a"]="v"

	map_long_to_short["bee"]="b"
	map_short_type["b"]="v"

	map_long_to_short["cee"]="c"
	map_short_type["c"]="v"

	map_long_to_short["dee"]="d"
	map_short_type["d"]="k"
	map_runtime["d"]=false

	map_short_type["e"]="v"

}

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
