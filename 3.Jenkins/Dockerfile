FROM rikorose/gcc-cmake:latest
WORKDIR /project

COPY . /project

RUN mkdir -p build && \
    cd build && \
    cmake .. -DBUILD_EXECUTABLE=ON && \
    cmake --build . -j
	
ENTRYPOINT ["/project/3.Jenkins/build/MyExecutable"]
