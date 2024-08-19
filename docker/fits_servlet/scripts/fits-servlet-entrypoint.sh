#! /bin/sh

# generate fits-service properties file from environment variables
cat <<-EOPROPS > $CATALINA_HOME/conf/fits-service.properties
max.objects.in.pool=${MAX_OBJECTS_IN_POOL:-5}
max.upload.file.size.MB=${MAX_UPLOAD_FILE_SIZE_MB:-2000}
max.request.size.MB=${MAX_REQUEST_SIZE_MB:-2000}
max.in.memory.file.size.MB=${MAX_IN_MEMORY_FILE_SIZE_MB:-4}
EOPROPS

export CATALINA_OPTS="${CATALINA_OPTS} -Dlog4j2.configurationFile=${CATALINA_HOME}/conf/log4j2.xml"
exec "$@"