FROM haskell:8.8.4

WORKDIR /opt/yst

RUN stack update

# Add just the .cabal file to capture dependencies
COPY ./cabal.project $WORKDIR
COPY ./yst.cabal     $WORKDIR
COPY ./stack.yaml    $WORKDIR

# Docker will cache this command as a layer, freeing us up to
# modify source code without re-installing dependencies
# (unless the .cabal file changes!)
RUN ulimit -n 4096
RUN stack test --resolver ghc-8.8.4  --only-dependencies --fast

# Add and Install Application Code
COPY . $WORKDIR
RUN ulimit -n 4096
RUN stack test --resolver ghc-8.8.4 --haddock --no-haddock-deps --ghc-options="-O0 -Wall -fno-warn-unused-do-bind"

CMD ["yst"]
