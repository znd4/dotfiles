

function proxy_main
    offproxy
    if curl --output /dev/null --silent --head --fail "https://google.com";
        echo "Off corporate network"
        echo "Proxy settings disabled"
    else
        echo "On corporate network"
        echo "Enabling proxy settings..."
        onproxy
        echo "Done"
    end
end

function onproxy
    set -l proxy_host http://internet.ford.com
    set -l proxy_port 83
    set -l proxy_url $proxy_host:$proxy_port
    
    # Terminal proxies
    # NPM also uses these env vars
    set -gx http_proxy $proxy_url
    set -gx https_proxy $proxy_url
    set -gx HTTP_PROXY $proxy_url
    set -gx HTTPS_PROXY $proxy_url
    set -gx no_proxy ".ford.com,localhost,127.0.0.1,204.130.41.105*"
    set -gx NO_PROXY ".ford.com,localhost,127.0.0.1,204.130.41.105*"
    
    # pip index
    set -gx PIP_INDEX_URL https://www.nexus.ford.com/repository/Ford_ML_public/simple
    
    # JVM proxies
    # set java_tool_options "-Dhttps.proxyHost=$proxy_host_no_protocol -Dhttps.proxyPort=$proxy_port -Dhttps.nonProxyHosts='*.ford.com|localhost' -Dhttp.proxyHost=$proxy_host_no_protocol -Dhttp.proxyHost=$proxy_port -Dhttp.nonProxyHosts='*.ford.com|localhost'"
    # set JAVA_TOOL_OPTIONS "-Dhttps.proxyHost=$proxy_host_no_protocol -Dhttps.proxyPort=$proxy_port -Dhttps.nonProxyHosts='*.ford.com|localhost' -Dhttp.proxyHost=$proxy_host_no_protocol -Dhttp.proxyHost=$proxy_port -Dhttp.nonProxyHosts='*.ford.com|localhost'"
end

function offproxy
    set -e http_proxy
    set -e https_proxy
    set -e HTTP_PROXY
    set -e HTTPS_PROXY
    set -e no_proxy
    set -e NO_PROXY

    # pypi index
    set -e PIP_INDEX_URL

    # JVM proxies
    # set -e java_tool_options
    # set -e JAVA_TOOL_OPTIONS
end

proxy_main