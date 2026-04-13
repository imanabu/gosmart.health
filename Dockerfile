FROM python:3.12-slim-bookworm

RUN useradd wagtail

EXPOSE 8000

ENV PYTHONUNBUFFERED=1 \
    PORT=8000 \
    UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy

# Install system dependencies required by Wagtail/Pillow
RUN apt-get update --yes --quiet && apt-get install --yes --quiet --no-install-recommends \
    build-essential \
    libjpeg62-turbo-dev \
    zlib1g-dev \
    libwebp-dev \
 && rm -rf /var/lib/apt/lists/*

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/local/bin/

WORKDIR /app
RUN chown wagtail:wagtail /app

COPY --chown=wagtail:wagtail pyproject.toml uv.lock ./

USER wagtail

# Install Python dependencies (no dev group in production)
RUN uv sync --frozen --no-group dev

COPY --chown=wagtail:wagtail . .

RUN uv run python manage.py collectstatic --noinput --clear --settings=mysite.settings.production

CMD set -xe; uv run python manage.py migrate --noinput --settings=mysite.settings.production; \
    uv run gunicorn mysite.wsgi:application
