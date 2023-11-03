FROM rikorose/gcc-cmake:latest
WORKDIR /project

COPY . /project

ARG BUILD_EXECUTABLE
RUN mkdir -p build && \
    cd build && \
    cmake .. -DBUILD_EXECUTABLE=BUILD_EXECUTABLE && \
    cmake --build . -j
	
ENTRYPOINT ["/project/build/MyExecutable"]
