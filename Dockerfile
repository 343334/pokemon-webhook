FROM jruby:9-onbuild
RUN echo America/Chicago | tee /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata
CMD ["bundle","exec","ruby","/usr/src/app/server.rb"]
