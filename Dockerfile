# image build example: docker -D build  --tag docker-yst:$GHC_VERSION .
# image run example:   docker run --rm docker-yst:$GHC_VERSION
# TODO add some ghcid use case

ARG  GHC_VERSION=8.8.4
ARG  REPO=yst

FROM haskell:$GHC_VERSION

# recall ARG GHC_VERSION without a value permits to use it inside the build stages
ARG  GHC_VERSION
ENV GHC_VERSION=$GHC_VERSION

ARG REPO
ENV REPO=$REPO

WORKDIR /opt/$REPO

RUN ulimit -n 8192

# Add just the files capturing dependencies
COPY ./yst.cabal      $WORKDIR
COPY ./stack.yaml     $WORKDIR

# Docker will cache this command as a layer, freeing us up to
# modify source code without re-installing dependencies
# (unless the .cabal file changes!)
RUN stack --resolver ghc-$GHC_VERSION --no-terminal $ARGS test --only-dependencies --fast

# Add and Install Application Code
COPY . $WORKDIR
RUN stack  --resolver ghc-$GHC_VERSION --no-terminal --local-bin-path $WORKDIR/bin \
           $ARGS test --haddock --no-haddock-deps --ghc-options="-O0 -Wall -fno-warn-unused-do-bind"

RUN apt-get update && apt-get install -y locales

RUN locale-gen --purge en_US.UTF-8  

RUN  echo -e 'LANG="en_US.UTF-8"\nLANGUAGE="en_US:en"\n' > /etc/default/locale
