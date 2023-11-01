FROM rikorose/gcc-cmake:latest
WORKING /project

COPY . /project

RUN cd 3.Jenkins && \
    mkdir -p build && \
    cd build && \
    cmake .. -DBUILD_EXECUTABLE=ON && \
    cmake --build . -j
	
ENTRYPOINT ["/project/3.Jenkins/build/MyExecutable"]