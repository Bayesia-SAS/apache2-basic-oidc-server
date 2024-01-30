# Apache2 Oidc basic server
A simple oidc server for docker. 

## Requirements

You need an OIDC provider with a client and user setup. You will also need to explicitly allow the valid redirect URI on the provider.

## Running the Container
You can run the docker container with the minimum setup using the following command:
```
docker run -d -p 80:80 -v site:/var/www:ro -e OIDCClientID=your_client_id -e OIDCClientSecret=your_client_secret -e ServerName=your_server_name -e OIDCProviderMetadataURL='https://example.com/openid-configuration' -e MinimumRole=user baptisterajaut/apache2-basic-oidc-server:latest
```
Replace `your_client_id`, `your_client_secret`, and `your_server_name` with your actual OIDC client ID, secret, and server name respectively. The `ServerName` environment variable is used to build the redirect URI for OIDC authentication.

Here are the other environment variables that you can use to configure the container:
- `OIDCClientID`: This specifies the ID of the OIDC client used for authentication. It's required for OIDC authentication and should be set.
- `OIDCClientSecret`: This specifies the secret key associated with the OIDC client used for authentication. It's required for OIDC authentication and should be set.
- `ServerName`: This is the domain used for the server. It's not required per say but you can only ommit it if you set yourself OIDCRedirectURI.
- `MinimumRole`: This specifies the minimum role required for accessing the server. Users who do not have this role will be redirected to the OIDC provider for authentication, while users with the specified role will be granted immediate access. The default value is "NOTCHANGED", so you should replace it with your actual minimum required role if you want to enforce access control.
- `OIDCProviderMetadataURL`: This specifies the URL of the OpenID Connect provider metadata document. It's required for OIDC authentication and should be set using the `-e` flag as shown in the command above.
- `SubPath`: This specifies a subpath under the main ServerName, useful if you use it behind a reverse proxy that only send requests to a subpath.
- `OIDCRedirectURI`: This specifies the URL to which users should be redirected after successful authentication. The entrypoint will build it from the ServerName "http://ServerName/redirect_uri", but you can change it to match your application's requirements if necessary.
- `RoleClaimName`: This specifies the name of the claim in the user's ID token that contains their role information. The default value is "roles", but you can change it to match your provider's token format if necessary.
- `IsBehindReverseProxy`: This specifies whether or not the server is behind a reverse proxy. (Default : FALSE) If set to "TRUE", the server will enable some HTTP headers that are required for OIDC authentication, while if set to "FALSE", these headers will be disabled and OIDC authentication may fail if used behind a reverse proxy.
- `ForceHTTPS`: This specifies whether or not to enforce HTTPS connections on all requests. (Default : FALSE) If set to "TRUE", the server will redirect all HTTP requests to their HTTPS equivalents, while if set to "FALSE", this behavior will be disabled and HTTP requests will be allowed.
- `EnableOIDCDebug`: This enables verbose logging for OIDC authentication events. If set to "TRUE", the server will log more detailed information about OIDC authentication attempts, which can be useful for debugging issues with the authentication process.
- `OIDCSessionInactivityTimeout`: This specifies the maximum amount of time (in seconds) that a user's session may remain inactive before being automatically invalidated by the server. The default value is 10, but you can change it to match your application's requirements if necessary.
- `ServerAdmin`: This specifies an email address for the Apache administrator. It's optional and can be left as is but it's not a good practice.
- `OIDCHeaders`: This specifies a list of HTTP headers that should be included in requests made by the server (only used if IsBehindReverseProxy is set to TRUE)
