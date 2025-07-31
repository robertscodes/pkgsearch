#!/bin/bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RESET='\033[0m'
BOLD='\033[1m'
ORANGE='\033[38;5;208m' # Approximated orange

usage() {
    echo -e "${CYAN}Usage:${RESET} $0 [aur search_term | github search_term | get-aur pkgname | get-github user/repo]"
    exit 1
}

error() {
    echo -e "${RED}${BOLD}Error:${RESET} $1"
    exit 1
}

info() {
    echo -e "${CYAN}${BOLD}$1${RESET}"
}

success() {
    echo -e "${GREEN}${BOLD}$1${RESET}"
}

search_aur() {
    term="$1"
    info "Searching AUR for \"${term}\"..."
    results=$(curl -s "https://aur.archlinux.org/rpc/?v=5&type=search&arg=${term}") || error "Failed to connect to AUR."
    count=$(echo "$results" | jq '.resultcount')
    if [[ "$count" -eq 0 ]]; then
        error "No results found in AUR."
    fi

    echo -e "${YELLOW}AUR results:${RESET}"

    # Prepare results as array of JSON objects
    mapfile -t aur_results < <(echo "$results" | jq -c '.results[]')
    
    # Print strictly first 20 results
    max=50
    for ((i = 0; i < max && i < count; i++)); do
        pkg="${aur_results[$i]}"
        name=$(echo "$pkg" | jq -r '.Name')
        desc=$(echo "$pkg" | jq -r '.Description')
        maintainer=$(echo "$pkg" | jq -r '.Maintainer')
        if [[ "$maintainer" == "null" ]]; then
            orphaned=" ${RED}{ORPHANED}${RESET}"
        else
            orphaned=""
        fi
        echo -e "${ORANGE}$((i+1)).${RESET} ${GREEN}${name}${RESET}"\:" ${RESET} ${orphaned} ${CYAN}${desc}${RESET}"
    done

    read -p "$(echo -e ${BOLD}Enter the number of the package to download, or 0 to cancel:${RESET} ) " choice
    if [[ "$choice" -le 0 || "$choice" -gt "$count" || "$choice" -gt "$max" ]]; then
        info "Cancelled."
        exit 0
    fi

    pkgname=$(echo "${aur_results[$((choice-1))]}" | jq -r '.Name')
    download_aur "$pkgname"
}

search_github() {
    term="$1"
    info "Searching GitHub for \"${term}\"..."
    results=$(curl -s "https://api.github.com/search/repositories?q=${term}&per_page=100") || error "Failed to connect to GitHub."
    count=$(echo "$results" | jq '.items | length')
    if [[ "$count" -eq 0 ]]; then
        error "No results found on GitHub."
    fi

    echo -e "${YELLOW}GitHub results:${RESET}"

    mapfile -t gh_results < <(echo "$results" | jq -c '.items[]')
    
    # Print strictly first 20 results
    max=50
    for ((i = 0; i < max && i < count; i++)); do
        repo="${gh_results[$i]}"
        name=$(echo "$repo" | jq -r '.full_name')
        desc=$(echo "$repo" | jq -r '.description')
    
        echo -e "${ORANGE}$((i+1)).${RESET} ${GREEN}${name}${RESET}"\:" ${CYAN}${desc}${RESET}"
    done

    read -p "$(echo -e ${BOLD}Enter the number of the repo to clone, or 0 to cancel:${RESET} ) " choice
    if [[ "$choice" -le 0 || "$choice" -gt "$count" || "$choice" -gt "$max" ]]; then
        info "Cancelled."
        exit 0
    fi

    repo=$(echo "${gh_results[$((choice-1))]}" | jq -r '.full_name')
    download_github "$repo"
}

download_aur() {
    pkgname="$1"
    url="https://aur.archlinux.org/cgit/aur.git/snapshot/${pkgname}.tar.gz"
    info "Downloading AUR package: ${pkgname}"
    curl -LO "$url" || error "Download failed."
    success "Downloaded ${pkgname}.tar.gz"
    echo -e "${CYAN}To build, run:${RESET} tar xvf ${pkgname}.tar.gz && cd ${pkgname} && makepkg -si"
}

download_github() {
    repo="$1"
    info "Cloning GitHub repository: ${repo}"
    git clone "https://github.com/${repo}.git" && success "Cloned ${repo}" || error "Clone failed."
}

if [[ $# -lt 2 ]]; then
    usage
fi

case "$1" in
    aur)
        search_aur "$2"
        ;;
    github)
        search_github "$2"
        ;;
    get-aur)
        download_aur "$2"
        ;;
    get-github)
        download_github "$2"
        ;;
    *)
        usage
        ;;
esac
