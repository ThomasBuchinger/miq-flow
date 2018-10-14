FROM manageiq/manageiq:gaprindashvili-5

RUN mkdir /opt/automate-gitops
COPY *.rb /opt/automate-gitops/
