#!/bin/bash

# TODO check for dependencies, capstan, etc. Download capstan osv-loader, init package, package compose 

osvProcessBuilderFolder="osv_process_builder_lib"
sparkForkFolder="spark_gv_fork"

sparkCapstanFolder="capstan_package"
sparkSoFilePath=${sparkCapstanFolder}/usr/lib

sparkOsvAppFolder="apache-spark-slave"

dest=$(pwd)
echo "Setting up in directory ${dest}"

mkdir -p $sparkSoFilePath

# Clone osv process builder lib
git clone ssh://git@gitlab.xlab.si:13022/mikelangelo/osv-process-builder-lib.git $osvProcessBuilderFolder
(cd $osvProcessBuilderFolder; git checkout feature/import_osv_process_builder_from_stormy_java_app; cd src/main/java/org/mikelangelo/osvprocessbuilder; make; mvn install:install-file -Dfile=osv-process-builder.jar -DgroupId=org.mikelangelo.osv -DartifactId=osvProcessBuilder -Dversion=0.1 -Dpackaging=jar; cp stormy-java/libOsvProcessBuilder.so $dest/${sparkSoFilePath}/)

# Add JAR to local maven repo, for now version 0.1
# In future, get current maven version, increment, save to var, increment in spark project

git clone git@github.com:gasper-vrhovsek/spark.git $sparkForkFolder
(cd $sparkForkFolder; git checkout feature/v.2.1.1_osvProcessBuilder; ./dev/make-distribution.sh --tgz -Phadoop-2.7; cp spark-2.1.1-bin-2.7.3.tgz ${dest}/${sparkOsvAppFolder})

(cp ${dest}/${sparkSoFilePath}/libOsvProcessBuilder.so ${sparkOsvAppFolder})
(cd ${sparkOsvAppFolder}; make)



# Make image with capstan


#(cd $sparkCapstanFolder; capstan package compose apache_spark_worker; capstan run --execute "--cwd=/spark /java.so -cp /spark/conf:/spark/jars/* -Dscala.usejavacp=true org.apache.spark.deploy.worker.Worker 172.16.122.4:7077")
