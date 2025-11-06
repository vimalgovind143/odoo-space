FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# System dependencies for building Python packages used by Odoo
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    nodejs \
    npm \
    libpq-dev \
    libxml2-dev \
    libxslt1-dev \
    libjpeg-dev \
    zlib1g-dev \
    libfreetype6-dev \
    liblcms2-dev \
    libwebp-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libldap2-dev \
    libsasl2-dev \
    libffi-dev \
    libssl-dev \
    pkg-config \
    xfonts-base \
    xfonts-75dpi \
    libxrender1 \
    libxext6 \
    libfontconfig1 \
    libjpeg62-turbo \
    curl \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

# Install wkhtmltopdf/wkhtmltoimage from .deb (packaging releases)
RUN set -eux; \
    curl -fsSL -o /tmp/wkhtmltox.deb \
      https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.bookworm_amd64.deb; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      fontconfig \
      fontconfig-config \
      fonts-dejavu-core \
      libx11-6 \
      libx11-data \
      libxrender1 \
      libxext6 \
      libxau6 \
      libxdmcp6 \
      libxcb1 \
      libpng16-16 \
      sensible-utils \
      ucf \
      x11-common \
      xfonts-encodings \
      xfonts-utils; \
    dpkg -i /tmp/wkhtmltox.deb || apt-get -y -f install; \
    rm -f /tmp/wkhtmltox.deb; \
    wkhtmltopdf --version; \
    wkhtmltoimage --version

WORKDIR /workspace

# Install Python dependencies from the repo
COPY requirements.txt /tmp/requirements.txt
RUN pip install --upgrade pip && \
    pip install -r /tmp/requirements.txt && \
    rm -rf /root/.cache/pip

EXPOSE 8069 8072

# Default command; docker-compose overrides this to pass config/admin password
CMD ["python", "odoo-bin", "-c", "/etc/odoo/odoo.conf"]