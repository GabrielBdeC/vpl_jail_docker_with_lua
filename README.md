Virtual Programming lab for Moodle - Execution server running on Docker.

Original project: http://vpl.dis.ulpgc.es/

### Build your own image

Clone this project, edit files as you need and build

#### Build

```shell
docker build -t img_vpl_jail .
```

#### Run

```shell
docker run -d --name vpl_jail --env FQDN=localhost --env PASSJAIL=PASS --env PASSOPENSSL=SSL --env PORT=80 --env SECURE_PORT=443 --cap-add=SYS_ADMIN -it -p 81:80 -p 444:443 img_vpl_jail
```

#### Development softwares installed

* C compiler (GNU)
* General purpose debugger (GNU)
* PHP interpreter
* Python interpreter
* Lua interpreter


#### Info
FQDN: variable of domain for generating self-signed SSL certificates.
PASSOPENSSL: variable of password for generating self-signed SSL certificates.
PASSJAIL: password to connect moodle with jail
PORT: port for http protocol. Needs to be the same as created
SECURE_PORT: port for https protocol. Needs to be the same as created

PORT and SECURE_PORT can't be mapped or VPL will get webshake error

--cap-add=SYS_ADMIN: without this parameter docker can't create the internal root jail for the executions.


#### Image
https://hub.docker.com/r/ifrscanoas/vpl-jail/
