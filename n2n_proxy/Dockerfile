FROM ginuerzh/gost as gost_src
FROM zctmdc/n2n_ntop

MAINTAINER zctmdc <zctmdc@outlook.com>

COPY --from=gost_src /bin/gost /bin/
# COPY ./dhcpd.conf /etc/dhcp/dhcpd.conf
COPY run.sh /usr/local/sbin/
COPY proxy.sh /usr/local/sbin/

RUN  chmod a+x /usr/local/sbin/run.sh \
	&& chmod a+x /usr/local/sbin/proxy.sh \
  && touch /var/lib/dhcp/dhcpd.leases \
	&& touch /var/log/n2n.log \
  && touch /var/log/proxy.log \
	&& touch /var/log/run.log 

ENV N2N_DESTINATION 192.168.0.0/16
ENV STATIC_IP 10.0.10.1
ENV N2N_GATEWAY 10.0.10.1
ENV N2N_GW FALSE
ENV N2N_NAT FALSE
ENV N2N_PROXY TRUE
ENV PROXY_ARGS -L=:1080

CMD ["/bin/bash","-c","/usr/local/sbin/run.sh"]