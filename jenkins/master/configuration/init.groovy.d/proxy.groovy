import jenkins.model.Jenkins

Jenkins jenkins = Jenkins.getInstance()

if (jenkins.proxy) {
  println("Proxy ALREADY set to: ${jenkins.proxy.name}:${jenkins.proxy.port} - leaving ..")
  return
} 

String httpProxy = System.getenv('HTTP_PROXY')
httpProxy = httpProxy.minus(~/^https?:\/\//)
println (httpProxy)
String httpNOProxyHosts = System.getenv('NO_PROXY')
String [] httpProxySplit = httpProxy.split(':')

String noProxyAmended = httpNOProxyHosts.replace(',','\r')

ProxyConfiguration proxy

if (httpProxySplit.size() == 2) {
    proxy = new ProxyConfiguration(
        httpProxySplit[0], httpProxySplit[1] as int, null, null, noProxyAmended) 
} else {
    proxy = new ProxyConfiguration(
        httpProxySplit[0], 80, null, null, noProxyAmended) 
}   

jenkins.proxy = proxy

println("Proxy set to: ${jenkins.proxy.name}:${jenkins.proxy.port}")

jenkins.save()
