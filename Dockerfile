# s2i-nginx-container
FROM registry.access.redhat.com/rhscl/s2i-base-rhel7

EXPOSE 8080

LABEL maintainer="elementsweb"

ENV NGINX_VERSION=1.9.9 \
    NAME=nginx

ENV SUMMARY="Platform for running Nginx web server to host assets" \
    DESCRIPTION="Nginx $NODEJS_VERSION docker container for hosting assets."

LABEL summary="$SUMMARY" \
      description="$DESCRIPTION" \
      io.k8s.description="$DESCRIPTION" \
      io.k8s.display-name="Nginx $NGINX_VERSION" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,$NAME,$NAME$NGINX_VERSION" \
      io.openshift.s2i.scripts-url="image:///usr/libexec/s2i" \
      io.s2i.scripts-url="image:///usr/libexec/s2i"

RUN wget http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz \
    && tar -xvf nginx-$NGINX_VERSION.tar.gz \
    && cd nginx-$NGINX_VERSION \
    && ./configure \
    && make \
    && make install

ENV PATH=/usr/local/nginx/sbin/:$PATH

# TODO (optional): Copy the builder files into /opt/app-root
# COPY ./<builder_folder>/ /opt/app-root/

# TODO: Copy the S2I scripts to /usr/libexec/s2i, since openshift/base-centos7 image
# sets io.openshift.s2i.scripts-url label that way, or update that label
COPY ./s2i/bin/ /usr/libexec/s2i

# Override the default nginx config
COPY ./s2i/nginx.conf /usr/local/nginx/conf/nginx.conf

ENV NGINX_DIR /usr/local/nginx

# Allow user 1001 to access everything for nginx
RUN touch ${NGINX_DIR}/logs/error.log \
    && touch ${NGINX_DIR}/logs/access.log \
    && chown -R 1001:0 $NGINX_DIR \
    && chmod -R a+rwx ${NGINX_DIR}/logs \
    && chmod -R ug+rwx ${NGINX_DIR}

# TODO: Drop the root user and make the content of /opt/app-root owned by user 1001
RUN chown -R 1001:1001 /opt/app-root

# This default user is created in the openshift/base-centos7 image
USER 1001

# TODO: Set the default CMD for the image
CMD ["/usr/libexec/s2i/usage"]
