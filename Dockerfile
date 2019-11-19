FROM quay.io/jupyteronopenshift/s2i-minimal-notebook-py36:2.4.0

RUN pip install pip
RUN pip install pandas

#change to root
USER 0

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
    
    
#install java
#RUN yum install -y java-1.8.0-openjdk
#RUN export JAVA_HOME=/opt/jdk1.8.0_201

RUN yum update -y && \
yum install -y wget && \
yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel && \
yum clean all
    
#change to normal user    
USER 1001
    
