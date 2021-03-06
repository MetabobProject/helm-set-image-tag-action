FROM alpine:3.14

LABEL "com.github.actions.icon"="arrow-up"
LABEL "com.github.actions.color"="green"

LABEL "repository"="https://github.com/rishindra23/helm-set-image-tag-action"
LABEL "homepage"="https://github.com/rishindra23/helm-set-image-tag-action"
LABEL "maintainer"="diranged"

RUN apk --no-cache add bash yq git patch py-pip
RUN pip install pybump yamale yamllint


COPY --from=alpine/helm:latest /usr/bin/helm /usr/bin/helm
COPY --from=jnorwood/helm-docs:v1.5.0 /usr/bin/helm-docs /usr/bin/helm-docs

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
