#!/bin/bash
TIMESTAMP=$(date +%Y%m%d_%H)
pg_dump -U evergreen -h localhost -f /backup/evergreen_${TIMESTAMP}.backup evergreendb
