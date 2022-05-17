FROM centos:7

RUN yum -y install openssl vsftpd && rm -rf /var/cache/yum/*

COPY vsftp.conf /etc/vsftp/vsftp.conf
COPY vsftp_ftps.conf /etc/vsftp/vsftp_ftps.conf
COPY vsftp_ftps_tls.conf /etc/vsftp/vsftp_ftps_tls.conf
COPY vsftp_ftps_implicit.conf /etc/vsftp/vsftp_ftps_implicit.conf
COPY start.sh /

RUN chmod +x /start.sh
RUN mkdir -p /home/vsftpd/
RUN chown -R ftp:ftp /home/vsftpd/

ENV FTP_USER **String**
ENV FTP_PASS **Random**
ENV PASV_ADDRESS **IPv4**

VOLUME /home/vsftpd
VOLUME /var/log/vsftpd

EXPOSE 20 21

ENTRYPOINT ["/start.sh"]
