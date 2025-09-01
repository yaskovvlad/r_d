FROM ghcr.io/dbt-labs/dbt-postgres:latest

# Таймзона та cron
ENV TZ=Europe/Kyiv
RUN apt-get update && apt-get install -y cron tzdata && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    rm -rf /var/lib/apt/lists/*

# Скрипт запуску dbt
COPY run_dbt.sh /usr/local/bin/run_dbt.sh
RUN chmod +x /usr/local/bin/run_dbt.sh

# Cron-джоба (13:00 щодня)
COPY dbt-cron /etc/cron.d/dbt-cron
RUN chmod 0644 /etc/cron.d/dbt-cron && crontab /etc/cron.d/dbt-cron

# Запускаємо cron у foreground
CMD ["cron", "-f"]
