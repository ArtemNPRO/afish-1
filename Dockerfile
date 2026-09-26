# syntax=docker/dockerfile:1
FROM python:3.12-slim

WORKDIR /srv

# tzdata обязателен: parser.py явно работает с зоной Europe/Moscow
# через zoneinfo, а slim-образ по умолчанию не содержит базу часовых поясов.
RUN apt-get update \
    && apt-get install -y --no-install-recommends tzdata \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# В репозитории файлы лежат в корне (без подпапки app/), поэтому
# явно собираем python-пакет "app" внутри образа при сборке.
RUN mkdir -p app
COPY __init__.py bot.py db.py logic.py main.py parser.py reminders.py ./app/

ENV DATA_DIR=/data
VOLUME ["/data"]

EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
