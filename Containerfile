FROM scratch AS ctx
COPY build_files /
COPY system_files /system_files
COPY decky /decky

FROM ghcr.io/ublue-os/bazzite:stable

LABEL org.opencontainers.image.title="GPD Win 1 Atomic Gaming"
LABEL org.opencontainers.image.description="Experimental GPD Win 1 gaming-mode adaptation using KWin and nested Gamescope"
LABEL org.opencontainers.image.source="https://github.com/ViccRondo/gpd-win1-atomic-gaming"
LABEL org.opencontainers.image.licenses="Apache-2.0"

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh

RUN bootc container lint
