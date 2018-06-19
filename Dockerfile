# ==================
# Compile CuraEngine
# ==================
FROM ubuntu:18.04

WORKDIR /srv
# Install compiler and library
RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y git cmake build-essential g++ libprotobuf-dev libarcus-dev

RUN git clone --depth 1 -b master https://github.com/Ultimaker/Cura.git \
 && git clone --depth 1 -b master https://github.com/Ultimaker/Uranium.git \
 && git clone --depth 1 -b master https://github.com/Ultimaker/fdm_materials.git \
 && git clone --depth 1 -b master https://github.com/Ultimaker/CuraEngine.git \
 && mkdir build \
 && cd build \
 && cmake .. \
 && make
COPY build/CuraEngine Cura/

# Clean up
RUN cd /srv \
 && rm -rf CuraEngine build


# ==============
# Cura CLI image
# ==============
FROM ubuntu:18.04

WORKDIR /srv

RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y --no-install-recommends python3 \
    python3-arcus python3-savitar \
    libprotobuf10 libgomp1 \
    python3-numpy python3-numpy-stl python3-scipy python3-magic python3-yaml

# Copy necessary parts
COPY --from 0 /srv/* /srv/

# Environment variables
ENV PYTHONPATH=/srv/Cura:/srv/Uranium:$PYTHONPATH

# Remove unneeded packages and clean up APT cache
RUN apt-get autoclean -y \
 && apt-get autoremove -y \
 && rm -rf /var/lib/apt/lists \
 && rm -rf /var/log/* \
 && rm -rf /tmp/*

ENTRYPOINT ["python3", "/srv/Cura/cura_app.py"]
