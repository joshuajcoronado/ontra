# Define global args
ARG FUNCTION_DIR="/var/task/"
ARG RUNTIME_VERSION="3.11"
ARG DEBIAN_VERSION="12"
ARG BUILD_VERSION="bookworm"

FROM python:${RUNTIME_VERSION}-${BUILD_VERSION} AS build-image

ARG FUNCTION_DIR
ARG RUNTIME_VERSION

RUN mkdir -p ${FUNCTION_DIR}

COPY app.py ${FUNCTION_DIR}

# Install Lambda Runtime Interface Client for Python
RUN python3 -m pip install -U pip awslambdaric --target ${FUNCTION_DIR}

# install lambda emulator for testing locally
ADD https://github.com/aws/aws-lambda-runtime-interface-emulator/releases/latest/download/aws-lambda-rie /usr/bin/aws-lambda-rie
COPY entry.sh /
RUN chmod 755 /usr/bin/aws-lambda-rie /entry.sh

# let's use a distroless iamge
FROM gcr.io/distroless/python3-debian${DEBIAN_VERSION}
ARG FUNCTION_DIR

WORKDIR ${FUNCTION_DIR}

# Copy in the built dependencies
COPY --from=build-image ${FUNCTION_DIR} ${FUNCTION_DIR}
COPY --from=build-image /usr/bin/aws-lambda-rie /usr/bin/aws-lambda-rie
COPY --from=build-image /entry.sh /entry.sh

ENTRYPOINT [ "/entry.sh" ]
CMD [ "app.handler" ]
