FROM python:3.9-slim-buster

ARG BUNDLE_DIR

RUN apt-get update && apt-get install -y ca-certificates
RUN pip3 install --upgrade pip && pip3 install kfp 

# This is a template Dockerfile for the bundle's invocation image
# You can customize it to use different base images, install tools and copy configuration files.
#
# Porter will use it as a template and append lines to it for the mixins
# and to set the CMD appropriately for the CNAB specification.
#
# Add the following line to porter.yaml to instruct Porter to use this template
# dockerfile: Dockerfile.tmpl

# You can control where the mixin's Dockerfile lines are inserted into this file by moving "# PORTER_MIXINS" line
# another location in this file. If you remove that line, the mixins generated content is appended to this file.
# exec mixin has no buildtime dependencies


# Use the BUNDLE_DIR build argument to copy files into the bundle
COPY . $BUNDLE_DIR
RUN rm -fr $BUNDLE_DIR/.cnab
COPY .cnab /cnab
COPY porter.yaml $BUNDLE_DIR/porter.yaml
WORKDIR $BUNDLE_DIR
CMD ["/cnab/app/run"]