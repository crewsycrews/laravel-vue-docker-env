FROM node:13.10
COPY --chown=node:node ./src/ /opt/vueapp/
WORKDIR /opt/vueapp
USER node
RUN yarn && yarn run build
