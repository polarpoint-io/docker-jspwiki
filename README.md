# docker-jspwiki
JSPWiki in a Docker container

Run the container (example) with the following command:

*docker run -d -p 8080:8080 --env="jspwiki_baseURL=http://localhost:8080/" --name jspwiki jspwiki*

Then point your browser at *http://localhost:8080/*

If you run it on a remote server, a docker run command like this one would do:

*docker run -d -p 8080:8080 --env="jspwiki_baseURL=http://mywonderfulserver.example.com:8080/ --name jspwiki jspwiki*
