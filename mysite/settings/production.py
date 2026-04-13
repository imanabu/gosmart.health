import os

from .base import *

DEBUG = False

# Read secrets from environment — set these on the VPS before starting gunicorn
SECRET_KEY = os.environ["DJANGO_SECRET_KEY"]

ALLOWED_HOSTS = os.environ.get("DJANGO_ALLOWED_HOSTS", "gosmart.health").split(",")

# ManifestStaticFilesStorage prevents stale JS/CSS assets after upgrades.
# https://docs.djangoproject.com/en/6.0/ref/contrib/staticfiles/#manifeststaticfilesstorage
STORAGES["staticfiles"]["BACKEND"] = (
    "django.contrib.staticfiles.storage.ManifestStaticFilesStorage"
)

try:
    from .local import *
except ImportError:
    pass
