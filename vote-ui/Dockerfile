FROM nginx:1.22-alpine
COPY . /usr/share/nginx/html
COPY vote-ui.conf.tmpl /etc/nginx/templates/vote-ui.conf.template
COPY nginx.conf /etc/nginx/nginx.conf
