# docker-jspwiki
JSPWiki in a Docker container

Run the container with the following command (Example):

    docker run -d -p 8080:8080 --env="jspwiki_baseURL=http://localhost:8080/" --name jspwiki jspwiki

Then point your browser at [http://localhost:8080/](http://localhost:8080/)

If you run it on a remote server, use a docker command like this :

    docker run -d -p 8080:8080 --env="jspwiki_baseURL=http://mywonderfulserver.example.com:8080/ --name jspwiki jspwiki
    
