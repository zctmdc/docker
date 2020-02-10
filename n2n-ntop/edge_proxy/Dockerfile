FROM ginuerzh/gost as gost_src
FROM zctmdc/n2n_ntop

MAINTAINER zctmdc <zctmdc@outlook.com>

COPY --from=gost_src /bin/gost/gost /usr/local/sbin/
COPY run.sh /usr/local/sbin/
COPY proxy.sh /usr/local/sbin/

RUN  chmod a+x /usr/local/sbin/run.sh \
	&& chmod a+x /usr/local/sbin/proxy.sh \
  && touch /var/log/proxy.log

ENV N2N_DESTINATION 192.168.0.0/16
ENV N2N_GATEWAY 10.0.0.1
ENV N2N_GW FALSE
ENV N2N_NAT FALSE

CMD ["/bin/sh","-c","/usr/local/sbin/run.sh"]