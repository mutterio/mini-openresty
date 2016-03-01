FROM mutterio/mini-base
ENV OPENRESTY_VERSION 1.9.7.3
ENV OPENRESTY_PREFIX /opt/openresty
ENV NGINX_PREFIX /opt/openresty/nginx
ENV VAR_PREFIX /var/nginx

# NginX prefix is automatically set by OpenResty to $OPENRESTY_PREFIX/nginx
# look for $ngx_prefix in https://github.com/openresty/ngx_openresty/blob/master/util/configure

RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.0.0/dumb-init_1.0.0_amd64
RUN chmod +x /usr/local/bin/dumb-init


RUN \
  apk update \
   && apk add make gcc musl-dev \
      pcre-dev openssl-dev zlib-dev ncurses-dev readline-dev \
      curl perl &&\
  mkdir -p /root/ngx_openresty \
  && cd /root/ngx_openresty \
  && echo "==> Downloading OpenResty..." \
  && curl -sSL http://openresty.org/download/openresty-${OPENRESTY_VERSION}.tar.gz | tar -xvz \
  && cd openresty-* \
  && echo "==> Configuring OpenResty..." \
  && readonly NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) \
  && echo "using upto $NPROC threads" \
  && ./configure \
    --prefix=$OPENRESTY_PREFIX \
    --http-client-body-temp-path=$VAR_PREFIX/client_body_temp \
    --http-proxy-temp-path=$VAR_PREFIX/proxy_temp \
    --http-log-path=$VAR_PREFIX/access.log \
    --error-log-path=$VAR_PREFIX/error.log \
    --pid-path=$VAR_PREFIX/nginx.pid \
    --lock-path=$VAR_PREFIX/nginx.lock \
    --with-luajit \
    --with-pcre-jit \
    --with-ipv6 \
    --with-http_gzip_static_module \
    --with-http_ssl_module \
    --without-http_ssi_module \
    --without-http_userid_module \
    --without-http_fastcgi_module \
    --without-http_uwsgi_module \
    --without-http_scgi_module \
    --without-http_memcached_module \
    -j${NPROC} \
  && echo "==> Building OpenResty..." \
  && make -j${NPROC} \
  && echo "==> Installing OpenResty..." \
  && make install \
  && echo "==> Finishing..." \
  && ln -sf $NGINX_PREFIX/sbin/nginx /usr/local/bin/nginx \
  && ln -sf $NGINX_PREFIX/sbin/nginx /usr/local/bin/openresty \
  && ln -sf $OPENRESTY_PREFIX/bin/resty /usr/local/bin/resty \
  && ln -sf $OPENRESTY_PREFIX/luajit/bin/luajit-* $OPENRESTY_PREFIX/luajit/bin/lua \
  && ln -sf $OPENRESTY_PREFIX/luajit/bin/luajit-* /usr/local/bin/lua \
  && apk del \
    make gcc musl-dev pcre-dev openssl-dev zlib-dev ncurses-dev readline-dev curl perl \
  && apk add \
    libpcrecpp libpcre16 libpcre32 openssl libssl1.0 pcre libgcc libstdc++ \
  && rm -rf /var/cache/apk/* \
  && rm -rf /root/ngx_openresty
WORKDIR $NGINX_PREFIX/
ADD scripts/ /usr/bin/
CMD ["dumb-init", "baseStart"]
