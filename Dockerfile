FROM  debian:bookworm-slim
LABEL maintainer="BAYESIA"

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  		apache2 \
  		libapache2-mod-auth-openidc \
  		curl sed\
  		ca-certificates \
  		&& apt-get clean && rm -rf /var/lib/apt/lists/*

ENV ServerAdmin=root@localhost
ENV ServerName=NOTCHANGED
ENV OIDCClientID=NOTCHANGED
ENV OIDCClientSecret=NOTCHANGED
ENV OIDCProviderMetadataURL=NOTCHANGED
ENV OIDCRedirectURI=NOTCHANGED
ENV RoleClaimName=roles
ENV MinimumRole=NOTCHANGED
ENV SubPath=NOTCHANGED
ENV IsBehindReverseProxy=TRUE
ENV ForceHTTPS=TRUE
ENV EnableOIDCDebug=FALSE
ENV OIDCSessionInactivityTimeout=10
ENV OIDCHeaders="X-Forwarded-Port X-Forwarded-Proto Forwarded X-Forwarded-Host"


RUN a2enmod proxy_http rewrite headers

RUN rm /etc/apache2/sites-enabled/000-default.conf
VOLUME ["/var/www"]
ENTRYPOINT /usr/local/bin/docker-entrypoint.sh

COPY conf/* /etc/apache2/sites-available/
RUN a2ensite oidc-default
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
