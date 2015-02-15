#
# Docker container for nzbget
#
FROM ubuntu:utopic

MAINTAINER Xavier Logerais "xavier@logerais.com"

ENV NZBGET_VERSION 14.1

ENV DEBIAN_FRONTEND noninteractive

# Install add-apt-repository
RUN apt-get install -y software-properties-common

# Add Ubuntu multiverse repository
RUN add-apt-repository -y multiverse

# Update packages list
RUN apt-get update

# Upgrade all installed packages
RUN apt-get upgrade -y

# Install prerequisites
RUN apt-get install -y wget build-essential pkg-config libncurses5-dev libssl-dev libxml2-dev unrar p7zip

# Download latest nzbget
RUN wget http://sourceforge.net/projects/nzbget/files/nzbget-${NZBGET_VERSION}.tar.gz -O /tmp/nzbget.tar.gz

# Uncompress nzbget archive, build, install and clean
RUN cd /tmp && tar vxzf nzbget.tar.gz && cd /tmp/nzbget-* && ./configure && make && make install && rm -rfv /tmp/nzbget*

# Create a dedicated user
RUN useradd -m nzbget

# Prepare directory structure and configuration
USER nzbget
WORKDIR /home/nzbget
RUN mkdir -p downloads/dst downloads/inter downloads/nzb downloads/queue downloads/tmp downloads/scripts
RUN cp /usr/local/share/nzbget/nzbget.conf .nzbget

# Expose the nzbget home
VOLUME /home/nzbget

# Expose the listening port
EXPOSE 6789

# Launch daemon
USER nzbget
WORKDIR /home/nzbget
CMD nzbget --daemon --configfile /home/nzbget/.nzbget
