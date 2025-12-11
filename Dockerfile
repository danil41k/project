# ===== builder stage =====
FROM python:3.11-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# ===== final stage =====
FROM python:3.11-alpine
WORKDIR /app
COPY --from=builder /root/.local /root/.local
ENV PATH=/root/.local/bin:$PATH

# create data dir with proper perms
RUN mkdir -p /app/data && chmod 755 /app/data

# copy app code
COPY . .

# environment defaults
ENV FLASK_APP=app.py
ENV FLASK_ENV=production
ENV DATABASE_PATH=/app/data/database.db

EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:5000/ || exit 1

CMD ["python", "app.py"]
