#!/bin/sh
# bash download-modern.sh && bash process.sh modern

directory="modern"

rm -rf "$directory"
mkdir -p "$directory"

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
    echo "https://e4ftl01.cr.usgs.gov//DP106/MOLT/MOD13Q1.006/2018.01.17/MOD13Q1.A2018017.h21v06.006.2018033223406.hdf"
    echo
    exit 1
}

prompt_credentials
  detect_app_approval() {
    approved=`curl -s -b "$cookiejar" -c "$cookiejar" -L --max-redirs 2 --netrc-file "$netrc" https://e4ftl01.cr.usgs.gov//DP106/MOLT/MOD13Q1.006/2018.01.17/MOD13Q1.A2018017.h21v06.006.2018033223406.hdf -w %{http_code} | tail  -1`
    if [ "$approved" -ne "302" ]; then
        # User didn't approve the app. Direct users to approve the app in URS
        exit_with_error "Please ensure that you have authorized the remote application by visiting the link below "
    fi
}

setup_auth_curl() {
    # Firstly, check if it require URS authentication
    status=$(curl -s -z "$(date)" -w %{http_code} https://e4ftl01.cr.usgs.gov//DP106/MOLT/MOD13Q1.006/2018.01.17/MOD13Q1.A2018017.h21v06.006.2018033223406.hdf | tail -1)
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
https://e4ftl01.cr.usgs.gov//MODV6_Cmp_B/MOLT/MOD13A2.006/2019.02.18/MOD13A2.A2019049.h21v05.006.2019073153002.hdf
https://e4ftl01.cr.usgs.gov//MODV6_Cmp_B/MOLT/MOD13A2.006/2019.02.18/MOD13A2.A2019049.h21v06.006.2019073153006.hdf
https://e4ftl01.cr.usgs.gov//MODV6_Cmp_B/MOLT/MOD13A2.006/2018.02.18/MOD13A2.A2018049.h21v06.006.2018066164826.hdf
https://e4ftl01.cr.usgs.gov//MODV6_Cmp_B/MOLT/MOD13A2.006/2018.02.18/MOD13A2.A2018049.h21v05.006.2018066165515.hdf
https://e4ftl01.cr.usgs.gov//MODV6_Cmp_B/MOLT/MOD13A2.006/2017.02.18/MOD13A2.A2017049.h21v06.006.2017066031027.hdf
https://e4ftl01.cr.usgs.gov//MODV6_Cmp_B/MOLT/MOD13A2.006/2017.02.18/MOD13A2.A2017049.h21v05.006.2017066031102.hdf
https://e4ftl01.cr.usgs.gov//MODV6_Cmp_B/MOLT/MOD13A2.006/2016.02.18/MOD13A2.A2016049.h21v06.006.2016109133506.hdf
https://e4ftl01.cr.usgs.gov//MODV6_Cmp_B/MOLT/MOD13A2.006/2016.02.18/MOD13A2.A2016049.h21v05.006.2016109133510.hdf
https://e4ftl01.cr.usgs.gov//MODV6_Cmp_B/MOLT/MOD13A2.006/2015.02.18/MOD13A2.A2015049.h21v06.006.2015297001533.hdf
https://e4ftl01.cr.usgs.gov//MODV6_Cmp_B/MOLT/MOD13A2.006/2015.02.18/MOD13A2.A2015049.h21v05.006.2015297001533.hdf
https://e4ftl01.cr.usgs.gov//MODV6_Cmp_B/MOLT/MOD13A2.006/2014.02.18/MOD13A2.A2014049.h21v06.006.2015274230240.hdf
https://e4ftl01.cr.usgs.gov//MODV6_Cmp_B/MOLT/MOD13A2.006/2014.02.18/MOD13A2.A2014049.h21v05.006.2015274230329.hdf
https://e4ftl01.cr.usgs.gov//MODV6_Cmp_B/MOLT/MOD13A2.006/2013.02.18/MOD13A2.A2013049.h21v05.006.2015256170803.hdf
https://e4ftl01.cr.usgs.gov//MODV6_Cmp_B/MOLT/MOD13A2.006/2013.02.18/MOD13A2.A2013049.h21v06.006.2015256170809.hdf
https://e4ftl01.cr.usgs.gov//MODV6_Cmp_B/MOLT/MOD13A2.006/2012.02.18/MOD13A2.A2012049.h21v05.006.2015238131629.hdf
https://e4ftl01.cr.usgs.gov//MODV6_Cmp_B/MOLT/MOD13A2.006/2012.02.18/MOD13A2.A2012049.h21v06.006.2015238134013.hdf
https://e4ftl01.cr.usgs.gov//MODV6_Cmp_B/MOLT/MOD13A2.006/2011.02.18/MOD13A2.A2011049.h21v06.006.2015216131931.hdf
https://e4ftl01.cr.usgs.gov//MODV6_Cmp_B/MOLT/MOD13A2.006/2011.02.18/MOD13A2.A2011049.h21v05.006.2015216133506.hdf
https://e4ftl01.cr.usgs.gov//MODV6_Cmp_B/MOLT/MOD13A2.006/2010.02.18/MOD13A2.A2010049.h21v06.006.2015200021445.hdf
https://e4ftl01.cr.usgs.gov//MODV6_Cmp_B/MOLT/MOD13A2.006/2010.02.18/MOD13A2.A2010049.h21v05.006.2015200021835.hdf
https://e4ftl01.cr.usgs.gov//MODV6_Cmp_B/MOLT/MOD13A2.006/2009.02.18/MOD13A2.A2009049.h21v05.006.2015187062612.hdf
https://e4ftl01.cr.usgs.gov//MODV6_Cmp_B/MOLT/MOD13A2.006/2009.02.18/MOD13A2.A2009049.h21v06.006.2015187061456.hdf
https://e4ftl01.cr.usgs.gov//MODV6_Cmp_B/MOLT/MOD13A2.006/2008.02.18/MOD13A2.A2008049.h21v05.006.2015172130558.hdf
https://e4ftl01.cr.usgs.gov//MODV6_Cmp_B/MOLT/MOD13A2.006/2008.02.18/MOD13A2.A2008049.h21v06.006.2015172130220.hdf
https://e4ftl01.cr.usgs.gov//MODV6_Cmp_B/MOLT/MOD13A2.006/2007.02.18/MOD13A2.A2007049.h21v05.006.2015161224604.hdf
https://e4ftl01.cr.usgs.gov//MODV6_Cmp_B/MOLT/MOD13A2.006/2007.02.18/MOD13A2.A2007049.h21v06.006.2015161224806.hdf
https://e4ftl01.cr.usgs.gov//MODV6_Cmp_B/MOLT/MOD13A2.006/2006.02.18/MOD13A2.A2006049.h21v06.006.2015161120657.hdf
https://e4ftl01.cr.usgs.gov//MODV6_Cmp_B/MOLT/MOD13A2.006/2006.02.18/MOD13A2.A2006049.h21v05.006.2015161115729.hdf
https://e4ftl01.cr.usgs.gov//MODV6_Cmp_B/MOLT/MOD13A2.006/2005.02.18/MOD13A2.A2005049.h21v06.006.2015157043712.hdf
https://e4ftl01.cr.usgs.gov//MODV6_Cmp_B/MOLT/MOD13A2.006/2005.02.18/MOD13A2.A2005049.h21v05.006.2015157043507.hdf
https://e4ftl01.cr.usgs.gov//MODV6_Cmp_B/MOLT/MOD13A2.006/2004.02.18/MOD13A2.A2004049.h21v06.006.2015154124827.hdf
https://e4ftl01.cr.usgs.gov//MODV6_Cmp_B/MOLT/MOD13A2.006/2004.02.18/MOD13A2.A2004049.h21v05.006.2015154124814.hdf
https://e4ftl01.cr.usgs.gov//MODV6_Cmp_B/MOLT/MOD13A2.006/2003.02.18/MOD13A2.A2003049.h21v05.006.2015156082829.hdf
https://e4ftl01.cr.usgs.gov//MODV6_Cmp_B/MOLT/MOD13A2.006/2003.02.18/MOD13A2.A2003049.h21v06.006.2015156082834.hdf
https://e4ftl01.cr.usgs.gov//MODV6_Cmp_B/MOLT/MOD13A2.006/2002.02.18/MOD13A2.A2002049.h21v06.006.2015146124725.hdf
https://e4ftl01.cr.usgs.gov//MODV6_Cmp_B/MOLT/MOD13A2.006/2002.02.18/MOD13A2.A2002049.h21v05.006.2015146124920.hdf
https://e4ftl01.cr.usgs.gov//MODV6_Cmp_B/MOLT/MOD13A2.006/2001.02.18/MOD13A2.A2001049.h21v06.006.2015142165720.hdf
https://e4ftl01.cr.usgs.gov//MODV6_Cmp_B/MOLT/MOD13A2.006/2001.02.18/MOD13A2.A2001049.h21v05.006.2015142182432.hdf
https://e4ftl01.cr.usgs.gov//MODV6_Cmp_B/MOLT/MOD13A2.006/2000.02.18/MOD13A2.A2000049.h21v06.006.2015136104632.hdf
https://e4ftl01.cr.usgs.gov//MODV6_Cmp_B/MOLT/MOD13A2.006/2000.02.18/MOD13A2.A2000049.h21v05.006.2015136104633.hdf
EDSCEOF
