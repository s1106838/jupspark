FROM quay.io/jupyteronopenshift/s2i-minimal-notebook-py36:2.4.0

RUN pip install pip
RUN pip install pandas

#change to root
USER 0

LABEL io.k8s.description="PySpark Jupyter Notebook." \
      io.k8s.display-name="PySpark Jupyter Notebook." \
      io.openshift.expose-services="8888:http,42000:http,42100:http"


# expose a port for the workers to connect back
EXPOSE 42000/tcp
# also expose a port for the block manager
EXPOSE 42100/tcp

# install dep
RUN rpm -Uvh https://rpm.nodesource.com/pub_4.x/el/7/x86_64/nodesource-release-el7-1.noarch.rpm
RUN yum install -y nodejs

#upgrade nodejs
RUN npm cache clean -f
RUN npm install -g n
RUN n stable

#install git in jupyter
RUN pip install --upgrade jupyterlab-git

RUN jupyter labextension install @jupyterlab/git@^0.5.0 && \
    npm cache clean --force && \
    rm -rf $CONDA_DIR/share/jupyter/lab/staging
    
#install pyspark    
RUN pip install pyspark
    
    
#install spark
RUN cd /opt
RUN wget http://www-eu.apache.org/dist/spark/spark-2.3.4/spark-2.3.4-bin-hadoop2.7.tgz
RUN tar -xzf spark-2.3.4-bin-hadoop2.7.tgz
RUN ln -s /opt/spark-2.2.1-bin-hadoop2.7  /opt/spark
RUN export SPARK_HOME=/opt/spark
RUN export PATH=$SPARK_HOME/bin:$PATH
    
#install java
RUN yum update -y && \
    yum install -y wget && \
    yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel && \
    yum clean all
    
    
#install hadoop
RUN yum -y install wget
RUN yum -y install which

# Setup env
USER root
ENV JAVA_HOME /usr/lib/jvm/jre-1.8.0
ENV HADOOP_USER hdfs
ENV HADOOP_PREFIX /usr/local/hadoop
ENV HADOOP_COMMON_HOME /usr/local/hadoop
ENV HADOOP_HDFS_HOME /usr/local/hadoop
ENV HADOOP_CONF_DIR /opt/cluster-conf

# download hadoop
RUN wget -q -O - http://apache.mirrors.pair.com/hadoop/common/hadoop-2.7.7/hadoop-2.7.7.tar.gz | tar -xzf - -C /usr/local \
&& ln -s /usr/local/hadoop-2.7.7 /usr/local/hadoop \
&& groupadd -r hadoop \
&& groupadd -r $HADOOP_USER && useradd -r -g $HADOOP_USER -G hadoop $HADOOP_USER

RUN mkdir -p $HADOOP_CONF_DIR

# Setup permissions and ownership (httpfs tomcat conf for 600 permissions)
RUN chown -R $HADOOP_USER:hadoop /usr/local/hadoop-2.7.7 && chmod -R 775 $HADOOP_CONF_DIR

# set up hadoop user and bin path
ENV HADOOP_USER_NAME $HADOOP_USER
ENV PATH="${HADOOP_PREFIX}/bin:${PATH}"




    
#change to normal user    
USER 1001
    
