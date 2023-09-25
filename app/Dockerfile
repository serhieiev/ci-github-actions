FROM python:3.11-slim-bookworm

WORKDIR /app
COPY requirements.txt ./
RUN pip install -r requirements.txt

COPY . .
RUN chmod +x /app/start.sh

EXPOSE 8000
CMD ["./start.sh"]
