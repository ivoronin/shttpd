#!/bin/sh -e

function send() {
    echo -e "$1\r"
}

function send_err() {
    send "HTTP/1.1 $1 $2"
    send "Content-type: text/plain"
    send "Content-length: ${#2}"
    send ""
    echo -n "$2"
    exit
}

function send_file() {
    send "HTTP/1.1 200 OK"
    send "Content-Type: $(file -bi $1)"
    send "Content-Length: $(stat -c%s $1)"
    send "Connection: close"
    send ""
    cat "$1"
    exit
}

function trim() {
    echo $1 | sed -e 's/[\r\n]$//'
}

read REQUEST
while true; do
    read HEADER
    test "$(trim "${HEADER}")" == "" && break
done

set -- $(trim "${REQUEST}")

test "$#" -ne 3 && send_err 400 "Bad Request"
test "$1" != "GET" && send_err 405 "Method Not Allowed"
test "$3" != "HTTP/1.0" && test "$3" != "HTTP/1.1" && send_err 505 "HTTP Version Not Supported"
test -f "$2" && send_file "$2" || send_err 403 "Forbidden"
