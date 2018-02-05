#!/bin/sh

# -------------------- Colors.
RED='\033[00;31m'
GREEN='\033[00;32m'
YELLOW='\033[00;33m'
BLUE='\033[00;34m'
PURPLE='\033[00;35m'
CYAN='\033[00;36m'
LIGHTGRAY='\033[00;37m'
# -------------------- Restore color.
RESTORE='\033[0m'

# Configuration
symbol="*"
paddingSymbol=" "
lineLength=75
charsToOption=3
charsToName=2

function generatePadding() {
    string="";
    for (( i=0; i < $2; i++ )); do
        string+="$1";
    done
    echo "$string";
}

# Generated configs
remainingLength=$(( $lineLength - 2 ));
line=$(generatePadding "${symbol}" "${lineLength}");
toOptionPadding=$(generatePadding "${paddingSymbol}" "${charsToOption}");
toNamePadding=$(generatePadding "$paddingSymbol" "$charsToName");

# generateText (text)
function generateText() {
    totalCharsToPad=$((remainingLength - ${#1}));
    charsToPadEachSide=$((totalCharsToPad / 2));
    padding=$(generatePadding "$paddingSymbol" "$charsToPadEachSide");
    totalChars=$(( ${#symbol} + ${#padding} + ${#1} + ${#padding} + ${#symbol} ));
    if [[ ${totalChars} < ${lineLength} ]]; then
        echo "${symbol}${padding}${BLUE}${1}${RESTORE}${padding}${paddingSymbol}${symbol}";
    else
        echo "${symbol}${padding}${BLUE}${1}${RESTORE}${padding}${symbol}";
    fi
}

# generateTitle (title)
function generateTitle() {
    echo "$line"
    generateText ""
    generateText "$1"
    generateText ""
    echo "$line"
}

# generateOption (dialogType, optionNumber, optionName)
function generateOption() {
    tempOptionPadding=$toOptionPadding
    tempNamePadding=$toNamePadding
    if [[ $1 == "options" ]]; then
        if [[ $3 == "Exit" ]] || [[ $3 == "Return to the main menu" ]]; then
            optionString="[0]"
        else
            optionString="[$2]"
        fi
    elif [[ $1 == "instructions" ]]; then
        optionString="$2."
    fi
    charsToPadName=$(( ${lineLength} - ${#symbol} - ${#tempOptionPadding} - ${#optionString} - ${#tempNamePadding} - ${#3} - ${#symbol} ));
    namePadding=$(generatePadding "$paddingSymbol" "$charsToPadName");
    echo "${symbol}${tempOptionPadding}${BLUE}${optionString}${RESTORE}${tempNamePadding}${LIGHTGRAY}${3}${RESTORE}${namePadding}${symbol}";
}

# generateOptionsFromArray (dialogType, array[options])
function generateOptionsFromArray() {
    index=1
    generateText ""
    for OPTION in "${@:2}"
    do
        if [[ "$1" == "message" ]]; then
            generateText "$OPTION"
        else
            generateOption "$1" "$index" "$OPTION"
        fi
        ((index++))
    done
    generateText ""
}

# generateDialog (dialogType, dialogTitle, array[options])
function generateDialog() {
    generateTitle "$2"
    generateOptionsFromArray "$1" "${@:3}"
    echo "$line";
}

# generateGoBackDialog (name, isNewLine)
function generateGoBackDialog() {
    if [[ $2 == "true" ]]; then
        echo -e "\n$line"
    else
        echo -e "$line"
    fi
    generateText ""
    generateOption "options" "0" "$1"
    generateText ""
    echo -e "$line"
}

# generateMessageDialog (title, array[message])
function generateMessageDialog() {
    if [[ "${#1}" > 0 ]]; then
        generateTitle "$1"
    fi
    generateOptionsFromArray "message" "${@:2}"
    echo "$line"
}
