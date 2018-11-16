# hassio-addon-traefik

### Configure password for basic auth

- Create a password with [online generator](http://www.htaccesstools.com/htpasswd-generator/)
- Copy user:password pair into `"basicAuth": "user:password"` section

### Configure traefik proxy

- Into `FILE` section you need to add the following code for each url you wont to redirect:

```
    {
        "id": "traefik",
        "entryPoint": "http",
        "host": "my-domain.xyx",
        "url": "http://192.168.1.x:8080"
    },
    {
        "id": "service-2",
        "entryPoint": "http",
        "host": "my-other-domain.xyx",
        "url": "http://192.168.1.x:12345"
    }
```