#!/bin/sh
# bash download-modern.sh && bash process.sh modern

directory="modern"
mkdir "$directory"

GREP_OPTIONS=''

cookiejar=$(mktemp cookies.XXXXXXXXXX)
netrc=$(mktemp netrc.XXXXXXXXXX)
chmod 0600 "$cookiejar" "$netrc"
function finish {
  rm -rf "$cookiejar" "$netrc"
}

trap finish EXIT
WGETRC="$wgetrc"

prompt_credentials() {
    echo "Enter your Earthdata Login or other provider supplied credentials"
    read -p "Username (james.fulford): " username
    username=${username:-james.fulford}
    read -s -p "Password: " password
    echo "machine urs.earthdata.nasa.gov login $username password $password" >> $netrc
    echo
}

exit_with_error() {
    echo
    echo "Unable to Retrieve Data"
    echo
    echo $1
    echo
    echo "https://e4ftl01.cr.usgs.gov//DP106/MOLT/MOD13Q1.006/2019.02.18/MOD13Q1.A2019049.h21v06.006.2019073153053.hdf"
    echo
    exit 1
}

prompt_credentials
  detect_app_approval() {
    approved=`curl -s -b "$cookiejar" -c "$cookiejar" -L --max-redirs 2 --netrc-file "$netrc" https://e4ftl01.cr.usgs.gov//DP106/MOLT/MOD13Q1.006/2019.02.18/MOD13Q1.A2019049.h21v06.006.2019073153053.hdf -w %{http_code} | tail  -1`
    if [ "$approved" -ne "302" ]; then
        # User didn't approve the app. Direct users to approve the app in URS
        exit_with_error "Please ensure that you have authorized the remote application by visiting the link below "
    fi
}

setup_auth_curl() {
    # Firstly, check if it require URS authentication
    status=$(curl -s -z "$(date)" -w %{http_code} https://e4ftl01.cr.usgs.gov//DP106/MOLT/MOD13Q1.006/2019.02.18/MOD13Q1.A2019049.h21v06.006.2019073153053.hdf | tail -1)
    if [[ "$status" -ne "200" && "$status" -ne "304" ]]; then
        # URS authentication is required. Now further check if the application/remote service is approved.
        detect_app_approval
    fi
}

setup_auth_wget() {
    # The safest way to auth via curl is netrc. Note: there's no checking or feedback
    # if login is unsuccessful
    touch ~/.netrc
    chmod 0600 ~/.netrc
    credentials=$(grep 'machine urs.earthdata.nasa.gov' ~/.netrc)
    if [ -z "$credentials" ]; then
        cat "$netrc" >> ~/.netrc
    fi
}

fetch_urls() {
  if command -v curl >/dev/null 2>&1; then
      setup_auth_curl
      while read -r line; do
        # Get everything after the last '/'
        filename="${line##*/}"

        # Strip everything after '?'
        stripped_query_params="${filename%%\?*}"

        echo "$stripped_query_params"
        curl -f -b "$cookiejar" -c "$cookiejar" -L --netrc-file "$netrc" -g -o $stripped_query_params -- $line && mv "$stripped_query_params" "$directory/$stripped_query_params" && echo || exit_with_error "Command failed with error. Please retrieve the data manually."
      done;
  else
      exit_with_error "Error: Could not find a command-line downloader.  Please install curl or wget"
  fi
}

fetch_urls <<'EDSCEOF'
https://e4ftl01.cr.usgs.gov//MODV6_Cmp_B/MOLT/MOD13A2.006/2019.02.02/MOD13A2.A2019033.h21v05.006.2019050214010.hdf
https://e4ftl01.cr.usgs.gov//MODV6_Cmp_B/MOLT/MOD13A2.006/2019.02.02/MOD13A2.A2019033.h21v06.006.2019050212544.hdf
https://e4ftl01.cr.usgs.gov//MODV6_Cmp_B/MOLT/MOD13A2.006/2018.02.02/MOD13A2.A2018033.h21v06.006.2018049223443.hdf
https://e4ftl01.cr.usgs.gov//MODV6_Cmp_B/MOLT/MOD13A2.006/2018.02.02/MOD13A2.A2018033.h21v05.006.2018049223505.hdf
EDSCEOF
