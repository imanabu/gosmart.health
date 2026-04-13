# gosmart.health

Personal website built with [Django](https://www.djangoproject.com/) and [Wagtail CMS](https://wagtail.org/).

## Stack

| Component | Version |
|-----------|---------|
| Python | 3.12 |
| Django | 6.x |
| Wagtail | 7.x |
| Database | SQLite |
| Package manager | [uv](https://docs.astral.sh/uv/) |

## Prerequisites

- [uv](https://docs.astral.sh/uv/getting-started/installation/) installed

## Local Development

### 1. Install dependencies

```bash
uv sync --group dev
```

### 2. Run database migrations

If the database does not exist, this will create it in the project
root as `db.sqlite3`

```bash
uv run python manage.py migrate --settings=mysite.settings.dev
```

### 3. Create an admin user

**Note** this will prompt the username and paswordd on the terminal.

```bash
uv run python manage.py createsuperuser --settings=mysite.settings.dev
```

### 4. Start the development server

```bash
uv run python manage.py runserver --settings=mysite.settings.dev
```

The site will be available at **http://127.0.0.1:8000**
The Wagtail admin is at **http://127.0.0.1:8000/admin/**

## Common Commands

```bash
# Create and apply new migrations after model changes
uv run python manage.py makemigrations --settings=mysite.settings.dev
uv run python manage.py migrate --settings=mysite.settings.dev

# Add a production dependency
uv add <package>

# Add a development-only dependency
uv add --group dev <package>

# Open a Django shell
uv run python manage.py shell --settings=mysite.settings.dev
```

## Project Structure

```
gosmart.health/
├── manage.py
├── pyproject.toml          # project dependencies (uv)
├── uv.lock                 # locked dependency versions
├── .python-version         # pinned to Python 3.12
├── Dockerfile              # production container image
├── mysite/                 # Django project configuration
│   ├── settings/
│   │   ├── base.py         # shared settings
│   │   ├── dev.py          # local development overrides
│   │   ├── production.py   # production overrides (reads from env)
│   │   └── local.py        # optional personal overrides (gitignored)
│   ├── urls.py
│   └── wsgi.py
├── home/                   # Wagtail home page app
└── search/                 # Wagtail search app
```

## Production Deployment (Hostinger VPS + OpenLightSpeed)

### Required environment variables

```bash
export DJANGO_SECRET_KEY="<generate a strong secret key>"
export DJANGO_ALLOWED_HOSTS="gosmart.health,www.gosmart.health"
```

Generate a secret key with:

```bash
uv run python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
```

### Deploy steps

```bash
uv sync --no-group dev
uv run python manage.py migrate --settings=mysite.settings.production
uv run python manage.py collectstatic --noinput --settings=mysite.settings.production
uv run gunicorn mysite.wsgi:application
```

Configure OpenLightSpeed to proxy requests to gunicorn on `127.0.0.1:8000` and serve the `static/` and `media/` directories directly.

## Hostinger VPS Instructions

### Starting or Stopping Gnuicorn

```bash
sudo systemctl start gunicorn-manabu
sudo systemctl restart gunicorn-manabu
sudo systemctl stop gunicorn-manabu
sudo systemctl status gunicorn-manabu

```
## To Test if Django is Running

1. Stop gunicorn-manabu as a service (see above)
2. Using the VS Code port forwarding of port 8000,
3. Run `start.sh` on the VPS and check the access from your desktop at home.

## 🚀 OpenLiteSpeed + Django Reverse Proxy Setup

This project is deployed on a Hostinger VPS using **OpenLiteSpeed (OLS)** as a reverse proxy to a **Gunicorn** backend running on port `8000`.

### 1. OpenLiteSpeed External App
In the OLS WebAdmin (Port 7080), navigate to **Virtual Hosts > [Your Domain] > External App**:
- **Name:** `gunicorn-manabu`
- **Type:** `Web Server`
- **Address:** `127.0.0.1:8000`
- **Max Connections:** `100`
- **Initial Request Timeout:** `60`

### 2. Rewrite Rules (The Proxy)
Under **Virtual Hosts > [Your Domain] > Rewrite**:
- **Enable Rewrite:** `Yes`
- **Rewrite Rules:**
  ```apache
  # Proxy all traffic to the Gunicorn External App
  RewriteRule ^(.*)$ http://gunicorn-manabu/$1 [P,L]

### 6. Systemd Gunicorn Service
Located at: `/etc/systemd/system/gunicorn.service`

```ini
[Unit]
Description=Gunicorn instance to serve Django
After=network.target

[Service]
User=root
Group=lshttpd
WorkingDirectory=/path/to/your/project
ExecStart=/path/to/venv/bin/gunicorn --workers 3 --bind 127.0.0.1:8000 project.wsgi:application

[Install]
WantedBy=multi-user.target
