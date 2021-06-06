FROM ubuntu:16.04
LABEL author="Vinicius Raupp Alves<viniciusrauppalves@gmail.com>"
LABEL modifier_author="Gabriel Carvalho<gabrielbdec@gmail.com>"

ENV VPLJAIL_SYS_VERSION=2.5.2
ENV VPLJAIL_INSTALL_DIR /etc/vpl
ENV FQDN localhost
ENV PASSOPENSSL Pass12345678
ENV PASSJAIL pass
ENV PORT=80
ENV SECURE_PORT=443
ENV LUAVERSION=5.4.3

RUN apt-get -qq update && apt-get -yqq install --no-install-recommends vim curl apt-utils autotools-dev automake  \
	openssl libssl-dev gconf2 firefox lua5.3 \
	make g++ gcc gdb nodejs php7.0-cli php7.0-sqlite python pydb python-tk \
	 locales supervisor && rm -rf /var/lib/apt/lists/* \
	&& localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

ENV LC_ALL en_US.UTF-8

WORKDIR /tmp/vpl-jail-system-$VPLJAIL_SYS_VERSION/
RUN 	curl http://vpl.dis.ulpgc.es/releases/vpl-jail-system-$VPLJAIL_SYS_VERSION.tar.gz | tar -zxC /tmp/ \
	&& ./configure && make && mkdir $VPLJAIL_INSTALL_DIR && cp src/vpl-jail-server $VPLJAIL_INSTALL_DIR \
	&& cp vpl-jail-system.conf $VPLJAIL_INSTALL_DIR \
	&& chmod 600 $VPLJAIL_INSTALL_DIR/vpl-jail-system.conf && cp vpl_*.sh /etc/vpl && chmod +x /etc/vpl/*.sh \
	&& cp vpl-jail-system.initd /etc/init.d/vpl-jail-system && chmod +x /etc/init.d/vpl-jail-system \
	&& mkdir /var/vpl-jail-system && chmod 0600 /var/vpl-jail-system \
	&& printf "[supervisord]\nnodaemon=false\n[program:vpl-jail-system]\ncommand=/etc/init.d/vpl-jail-system start" >> /etc/supervisor/supervisord.conf \
	&& rm -rf /tmp/vpl-jail-system-$VPLJAIL_SYS_VERSION/

WORKDIR /tmp/lua/
RUN 	curl -R -O http://www.lua.org/ftp/lua-$LUAVERSION.tar.gz \
	&& ls \
	&& tar zxf lua-$LUAVERSION.tar.gz \
	&& cd lua-$LUAVERSION \
	&& vim Makefile -c ":%s/INSTALL_TOP= \/usr\/local/INSTALL_TOP= \/usr/g | :wq" \
	&& make all test \
	&& make install \
	&& cd .. \
	&& rm -rf /tmp/lua

WORKDIR /etc/vpl/
COPY entrypoint.sh /
CMD ["/entrypoint.sh"]
RUN		chmod +x entrypoint.sh