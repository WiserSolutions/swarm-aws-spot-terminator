FROM docker:17.07.0-ce
RUN apk add --no-cache curl
ADD ./poll_for_termination.sh /
CMD ./poll_for_termination.sh
