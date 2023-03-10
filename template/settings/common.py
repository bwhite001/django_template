"""Common settings."""

import os

# Build paths inside the project like this: os.path.join(BASE_DIR, ...)
BASE_DIR = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# Environment
ENVIRONMENT = os.environ.get("ENVIRONMENT", None)
if ENVIRONMENT == "dev_local":
    DEVNAME = os.environ["DEVNAME"]

# Debug
DEBUG_ENVS = ("dev_local", "dev", "test")
DEBUG = ENVIRONMENT in DEBUG_ENVS

# Trust nginx
USE_X_FORWARDED_HOST = True
SECURE_PROXY_SSL_HEADER = ("HTTP_X_FORWARDED_PROTO", "https")

# Allowed hosts, Site domain and URL
ALLOWED_HOSTS = ["*"]
MY_SITE_DOMAIN = os.environ.get("SITE_DOMAIN", "").split("|")[0]
SITE_URL = f"{os.environ.get('SITE_PROTOCOL', '')}://{MY_SITE_DOMAIN}"

# File locations
if ENVIRONMENT == "dev_local":
    STORAGE_DIR = BASE_DIR
    NGINX_STATIC_DIR = None
else:
    STORAGE_DIR = "/storage"
    NGINX_STATIC_DIR = "/static"

STATIC_ROOT = os.path.join(BASE_DIR, "static")
MEDIA_ROOT = os.path.join(STORAGE_DIR, "media")

STATIC_URL = "/static/"
MEDIA_URL = "/media/"

DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"
