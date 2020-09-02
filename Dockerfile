FROM haskell:8

WORKDIR /opt/yst

RUN cabal update

# Add just the .cabal file to capture dependencies
COPY ./cabal.project $WORKDIR/cabal.project
COPY ./yst.cabal     $WORKDIR/yst.cabal

# Docker will cache this command as a layer, freeing us up to
# modify source code without re-installing dependencies
# (unless the .cabal file changes!)
RUN cabal install --verbose --only-dependencies -j4

# Add and Install Application Code
COPY . $WORKDIR
RUN cabal install

CMD ["yst"]
