# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
    local var="$1"
    local fileVar="${var}_FILE"
    local def="${2:-}"
# If the first character of parameter is an exclamation point (!), a level of
# variable indirection is introduced. Bash uses the value of the variable
# formed from the rest of parameter as the name of the variable; this variable
# is then expanded and that value is used in the rest of the substitution,
# rather than the value of parameter itself. This is known as indirect
# expansion.  The exceptions to this are the expansions of  ${!prefix*} and
# ${!name[@]} described below. The exclamation point must immediately follow
# the left brace in order to introduce indirection.
    if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
        echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
        exit 1
    fi
    local val="$def"
    if [ "${!var:-}" ]; then
        val="${!var}"
    elif [ "${!fileVar:-}" ]; then
        val="$(< "${!fileVar}")"
    fi
    export "$var"="$val"
    unset "$fileVar"
}

