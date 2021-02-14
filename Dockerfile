# image build example: docker -D build  --tag docker-yst:$GCC_VERSION .
# image run example:   docker run --rm docker-yst:$GCC_VERSION
# TODO add some ghcid use case

ARG  GCC_VERSION=8.8.4

FROM haskell:$GCC_VERSION

# recall ARG GCC_VERSION without a value permits to use it inside the build stages
ARG  GCC_VERSION

WORKDIR /opt/yst

RUN stack config set system-ghc --global true

RUN stack update

# Add just the files capturing dependencies
COPY ./yst.cabal      $WORKDIR
COPY ./stack.yaml     $WORKDIR

# Docker will cache this command as a layer, freeing us up to
# modify source code without re-installing dependencies
# (unless the .cabal file changes!)
RUN ulimit -n 8192
RUN stack --resolver ghc-$GCC_VERSION --no-terminal $ARGS test --only-dependencies --fast

# Add and Install Application Code
COPY . $WORKDIR
RUN stack  --resolver ghc-$GCC_VERSION --no-terminal --local-bin-path $WORKDIR/bin \
           $ARGS test --haddock --no-haddock-deps --ghc-options="-O0 -Wall -fno-warn-unused-do-bind"

# ENV PATH="/opt/yst/bin:${PATH}"

RUN apt-get update && apt-get install -y vim

RUN apt-get update && apt-get install -y locales

RUN locale-gen en_US.UTF-8  
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8  

RUN stack --resolver ghc-$GCC_VERSION --no-terminal install ghcid --stack-yaml ghcid-stack.yaml

RUN stack --resolver ghc-$GCC_VERSION --no-terminal install hlint --stack-yaml hlint-stack.yaml

CMD ["stack", "exec", "ghcid"]
