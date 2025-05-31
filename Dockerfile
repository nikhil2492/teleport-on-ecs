FROM ubuntu:22.04
ENV DEBIAN_FRONTEND noninteractive
ENV TZ=Asia/Kolkata

RUN apt-get update \
    && apt-get install -y apache2 awscli openssh-server \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /mnt/teleport_records

###### Setup SSH ####
RUN mkdir /var/run/sshd
#RUN mkdir /etc/ssh
RUN ssh-keygen -A

RUN sed -i 's/#PubkeyAuthentication/PubkeyAuthentication/' /etc/ssh/sshd_config
#RUN sed -i 's/#PasswordAuthentication/PasswordAuthentication no/' /etc/ssh/sshd_config
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN mkdir -p /root/.ssh
COPY authorized_keys /root/.ssh/
RUN chmod 400 /root/.ssh/authorized_keys

COPY teleport /usr/local/bin/
COPY tctl /usr/local/bin/
COPY tsh /usr/local/bin/
COPY tbot /usr/local/bin/

EXPOSE 8888
EXPOSE 22

VOLUME ["/var/lib/teleport", "/etc/teleport", "/mnt/teleport_records"]

# Set the entrypoint command

#ENTRYPOINT ["/usr/local/bin/teleport"]
#CMD ["start", "--config=/etc/teleport/teleport.yaml"]
ENTRYPOINT service ssh start && /usr/local/bin/teleport start --config=/etc/teleport/teleport.yaml
