FROM haskell:8.8.4

WORKDIR /opt/yst

RUN stack config set system-ghc --global true

RUN stack update

# Add just the files capturing dependencies
COPY ./yst.cabal      $WORKDIR
COPY ./stack.yaml     $WORKDIR

# Docker will cache this command as a layer, freeing us up to
# modify source code without re-installing dependencies
# (unless the .cabal file changes!)
RUN ulimit -n 4096
RUN stack --resolver ghc-8.8.4 --no-terminal $ARGS test --only-dependencies --fast

# Add and Install Application Code
COPY . $WORKDIR
RUN ulimit -n 4096
RUN stack  --resolver ghc-8.8.4 --no-terminal --local-bin-path $WORKDIR/bin \
           $ARGS test --haddock --no-haddock-deps --ghc-options="-O0 -Wall -fno-warn-unused-do-bind"

ENV PATH="/opt/yst/bin:${PATH}"

CMD ["yst"]
