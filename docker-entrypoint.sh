#!/bin/bash
echo "--------------------------------------------------------------"
echo "                 BASIC OIDC APACHE 2 SERVER "
e=0
if [ "$OIDCClientID" == "NOTCHANGED" ];then
    >&2 echo "FATAL : OIDC Client ID (OIDCClientID) has not been set !"
    e=1
fi

if [ "$OIDCClientSecret" == "NOTCHANGED" ];then
    >&2 echo "FATAL : OIDC Client Secret (OIDCClientSecret) has not been set !"
    e=1
fi

if [ "$OIDCProviderMetadataURL" == "NOTCHANGED" ];then
    >&2 echo "FATAL : OIDC Provider Metadata URL (OIDCProviderMetadataURL) has not been set !"
    e=1
fi

if [ "$ServerAdmin" == "root@localhost" ];then
    >&2 echo "Warning : It's good practice to set a server admin mail (ServerAdmin)"
fi

if [ "$MinimumRole" == "NOTCHANGED" ];then
    >&2 echo "FATAL : OIDC minimum role (MinimumRole) has not been set !"
    e=1
fi
if [ "$ForceHTTPS" == "TRUE" ]; then
    >&2 echo "INFO : ForceHTTPS is TRUE, enabling HTTPS everywhere !"
    HTTP_MODE="https"
else 
    >&2 echo "INFO : ForceHTTPS is not set to TRUE !"
    HTTP_MODE="http"
fi
if [ "$OIDCRedirectURI" == "NOTCHANGED" ];then
    if [ "$ServerName" == "NOTCHANGED" ];then
        >&2 echo "FATAL : OIDC Redirect URI (OIDCRedirectURI) is not set, and since neither is ServerName, i can't make it myself !"
        e=1
    else
        if [ "$SubPath" == "NOTCHANGED" ];then
            OIDCRedirectURI="$HTTP_MODE://$ServerName/redirect_uri"
            >&2 echo "WARNING : OIDC Redirect URI (OIDCRedirectURI) and subpath have not been set, using $HTTP_MODE and server name alone, this could cause some weird behiavour !"
        else
            OIDCRedirectURI="$HTTP_MODE://$ServerName/$SubPath/redirect_uri"
            >&2 echo "INFO : OIDC Redirect URI (OIDCRedirectURI) has not been set, using $HTTP_MODE, server name and subpath for the redirect uri. This SHOULD be fine."
        fi
    fi

fi

if [ "$IsBehindReverseProxy" == "TRUE" ]; then
    >&2 echo "INFO : IsBehindReverseProxy is TRUE, enabling OIDCXForwardedHeaders $OIDCHeaders for OIDC ! This may CRASH apache children if the headers are not present !"
    sed -i "s/#ENABLEOIDCHEADERS//" /etc/apache2/sites-available/oidc-default.conf
else 
    if [ "$IsBehindReverseProxy" == "FALSE" ]; then
        >&2 echo "INFO : IsBehindReverseProxy is FALSE, OIDCXForwardedHeaders won't be set ! This will cause OIDC authentification to NOT WORK behind a reverse proxy !"
    else 
        >&2 echo "FATAL : IsBehindReverseProxy should be explicitly TRUE or FALSE (case sensitive) !"
        e=1
    fi
fi

if [ "$OIDCSessionInactivityTimeout" -lt 10 ]; then
    >&2 echo "WARNING : OIDCSessionInactivityTimeout minimum is 10. Yeah I'm aware it's not great."
    OIDCSessionInactivityTimeout=10
fi

# Apache gets grumpy about PID files pre-existing
rm -f /var/run/apache2/apache2.pid

ln -sf /dev/stdout /var/log/apache2/access.log
ln -sf /dev/stderr /var/log/apache2/error.log
APACHERESULT=$(/usr/sbin/apache2ctl configtest 2>&1)
if [ $? -ne 0 ]; then
    >&2 echo "FATAL : Apache config test failed !! Reason below :"
    echo "$APACHERESULT"
    e=1
fi

if [ "$e" -eq 1 ];then
    >&2 echo "ABORTING : Fix those issues and then try again !"
    >&2 echo "--------------------------------------------------------------"
    sleep 5 # Rancher 1.6 sheneningans
    exit 1
fi
# Start Apache in foreground
echo "INFO : Config ready and LGTM, starting Apache now, good luck !"
echo "--------------------------------------------------------------"
/usr/sbin/apache2ctl -DFOREGROUND
