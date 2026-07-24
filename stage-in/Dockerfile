FROM rockylinux/rockylinux:10.1-minimal AS builder

RUN microdnf -y update && \
    microdnf -y install curl tar python3 python3-pip python3-setuptools gcc && \
    microdnf clean all

RUN curl -L https://github.com/pypa/hatch/releases/download/hatch-v1.14.0/hatch-x86_64-unknown-linux-gnu.tar.gz \
      -o /tmp/hatch.tar.gz && \
    tar -xzf /tmp/hatch.tar.gz -C /tmp && \
    install -m 0755 /tmp/hatch /usr/local/bin/hatch && \
    rm -rf /tmp/hatch /tmp/hatch.tar.gz

ARG YQ_VERSION=v4.44.3
RUN curl -L "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64" \
      -o /usr/local/bin/yq && \
    chmod +x /usr/local/bin/yq && \
    /usr/local/bin/yq --version

WORKDIR /src
COPY . /src

RUN hatch build -t wheel

FROM rockylinux/rockylinux:10.1-minimal AS runtime

RUN microdnf -y update && \
    microdnf -y install python3 python3-pip git jq && \
    microdnf clean all

COPY --from=builder /usr/local/bin/yq /usr/bin/yq

ENV HOME=/home/neo
RUN /usr/sbin/groupadd -g 2000 neo && \
    /usr/sbin/useradd -u 2000 -g 2000 -m -d ${HOME} -s /sbin/nologin neo && \
    mkdir -p /app && \
    chown -R 2000:2000 /app ${HOME}

USER neo
WORKDIR /app

ENV VIRTUAL_ENV=/app/venv
ENV PATH="${VIRTUAL_ENV}/bin:${PATH}:/usr/bin"
RUN python3 -m venv /app/venv && \
    /app/venv/bin/pip install --no-cache-dir --upgrade pip

COPY --from=builder /src/dist/*.whl /app/dist/

RUN /app/venv/bin/pip install --no-cache-dir /app/dist/*.whl && \
    stage-in --help
