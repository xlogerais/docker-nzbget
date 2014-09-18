#
# Docker container for nzbget
#
FROM ubuntu:14.04

MAINTAINER Xavier Logerais "xavier@logerais.com"

#ENV NZBGET_VERSION 13.0
ENV NZBGET_VERSION 14.0-testing-r1121
ENV DEBIAN_FRONTEND noninteractive


RUN apt-get update
#RUN apt-get install -y nzbget

# Install prerequisites
RUN apt-get install wget build-essential pkg-config libncurses5-dev libssl-dev libxml2-dev -y

# Download
RUN wget http://sourceforge.net/projects/nzbget/files/nzbget-${NZBGET_VERSION}.tar.gz -O /tmp/nzbget.tar.gz

# Uncompress
WORKDIR /tmp
RUN tar vxzf nzbget.tar.gz

# Build
RUN cd /tmp/nzbget-* && ./configure && make && make install

# Clean
RUN rm -rfv /tmp/nzbget*

# Create a dedicated user
RUN useradd -m nzbget

# Prepare directory structure
USER nzbget
WORKDIR /home/nzbget
RUN sed -e 's,/downloads,/home/nzbget/downloads,g' /usr/local/share/nzbget/nzbget.conf > .nzbget
RUN mkdir -p downloads/dst

# Expose the listening port
EXPOSE 6789

# Expose the nzbget home
VOLUME /home/nzbget

# Launch daemon
USER nzbget
WORKDIR /home/nzbget
CMD nzbget --configfile /home/nzbget/.nzbget --daemon
#ENTRYPOINT ["nzbget"]
#CMD ["-D"]