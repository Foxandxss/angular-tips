FROM klakegg/hugo:onbuild AS hugo

FROM nginx:latest
COPY --from=hugo /target /usr/share/nginx/html
COPY /deploy/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80