
<h2>Run/debug the Micronaut application in native (no JVM) mode inside docker container</h2>


1. Run maven target `mvn package -Dpackaging=docker-native` to build native application, profile: `graalvm`

2. Copy target/Dockerfile, name it `Debug.dockerfile` and place it into the same `target` folder.  
Change it:
   ```Dockerfile
   # GraalVM image based on some image, here on Oracle Linux 9
   ARG BASE_IMAGE="ghcr.io/graalvm/native-image-community:17-ol9"
   # because on dependencies on system libraies it's better to reuse same image for run
   ARG BASE_IMAGE_RUN="oraclelinux:9"
   
   FROM ${BASE_IMAGE} AS builder
   WORKDIR /home/app
   COPY classes /home/app/classes
   COPY dependency/* /home/app/libs/
   COPY *.args /home/app/graalvm-native-image.args
   #Here main class of your server application
   ARG CLASS_NAME="example.micronaut.Application"
   RUN native-image @/home/app/graalvm-native-image.args -H:Class=${CLASS_NAME} -g -H:Name=application -cp "/home/app/libs/*:/home/app/classes/"
   FROM ${BASE_IMAGE_RUN}
   ARG EXTRA_CMD=""
   RUN if [[ -n "${EXTRA_CMD}" ]] ; then eval ${EXTRA_CMD} ; fi
   
   COPY --from=builder /home/app/application /app/application
   #copy debug info of application
   COPY --from=builder /home/app/application.debug /app/application.debug
   
   #install gdbserver to debug
   RUN dnf install -y gdb-gdbserver
   ARG PORT=8080
   EXPOSE ${PORT}
   ```
3. Run "Build image" for `Debug.dockerfile`: click on the gutter in the file ->Build image
4. Extract application and application.debug into `target` or your output directory: 
    - select the built image in the Services view
    - click `Show Layers` button
    - click `Analyse image for more information`
    - Select the layer with "COPY" of `application`/`application.debug` file and press "Download file" button
    - place the downloaded files into `target` folder

5. Check that `application`/`application.debug` is executable `chmod 755 target/application`

6. Configure `GraalVM Native Image` run configuration:
   - Executable: target/application 
   - Use classpath module: `demo`

9. Run on target: Docker
   Dockerfile: target/Dockerfile.debug
   Optional:
      Image tag: gdbserver
      Run options: add `-p 8080:8080`
10. Set break point

11. Press debug on your new created run configuration
 

