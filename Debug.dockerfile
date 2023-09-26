# GraalVM image based on some image, here on Oracle Linux 9
ARG BASE_IMAGE="ghcr.io/graalvm/native-image-community:17-ol9"
# because on dependencies on system libraies it's better to reuse same image for run
ARG BASE_IMAGE_RUN="oraclelinux:9"

FROM ${BASE_IMAGE} AS builder
WORKDIR /home/app
COPY classes /home/app/classes
COPY dependency/* /home/app/libs/
COPY *.args /home/app/graalvm-native-image.args
COPY tmp /app/tmp
#Here main class of your server application
ARG CLASS_NAME="example.micronaut.Application"
RUN native-image --verbose -cp /home/app/classes:/home/app/libs/*.jar @/home/app/graalvm-native-image.args -H:Class=${CLASS_NAME} -g -H:Name=application
FROM ${BASE_IMAGE_RUN}
ARG EXTRA_CMD=""
RUN if [[ -n "${EXTRA_CMD}" ]] ; then eval ${EXTRA_CMD} ; fi
COPY --from=builder /app/application /app/application

#copy debug info of application
COPY --from=builder /app/application.debug /app/application.debug
#install gdbserver to debug
RUN dnf install -y gdb-gdbserver
ARG PORT=8080
EXPOSE ${PORT}