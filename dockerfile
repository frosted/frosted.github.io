# Old Docker file contents
#FROM nginx:stable-alpine
#COPY _site /usr/share/nginx/html

# Create a Jekyll container from a Ruby Alpine image

FROM nginx:stable-alpine

# Add Jekyll dependencies to Alpine
RUN apk update
RUN apk add --no-cache build-base gcc cmake git

# Update the Ruby bundler and install Jekyll
RUN gem update bundler && gem install bundler jekyll