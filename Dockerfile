FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

# Exponer el puerto de Gradio
EXPOSE 7860

# Variable de entorno para ver prints en tiempo real
ENV PYTHONUNBUFFERED=1

CMD ["python", "app.py"]

