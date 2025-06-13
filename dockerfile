# Usa una imagen base oficial de Python. Recomendamos la 3.11 porque es la que has usado.
# 'slim-buster' es una versión ligera de Debian, ideal para contenedores.
FROM python:3.11-slim-buster

# Establece el directorio de trabajo dentro del contenedor a '/app'.
# Todos los comandos subsiguientes se ejecutarán desde aquí.
WORKDIR /app

# Copia el archivo principal del backend de Python a la raíz del directorio de trabajo del contenedor.
COPY playground.py .

# Intenta copiar la base de datos SQLite si existe.
# Si no usas 'tmp/agents.db' o esta carpeta no existe localmente,
# puedes comentar o eliminar la siguiente línea para evitar errores durante la construcción.
# COPY tmp/agents.db tmp/

# Instala todas las dependencias de Python que sabemos que necesitas para Agno.
# `--no-cache-dir` ayuda a mantener la imagen más pequeña.
RUN pip install --no-cache-dir agno[groq] fastapi sqlalchemy duckduckgo-search yfinance uvicorn python-dotenv

# Ahora, vamos a preparar el frontend de Next.js.
# Primero, copia los archivos de configuración de pnpm y el gestor de paquetes.
COPY package.json .
COPY pnpm-lock.yaml .

# Instala pnpm globalmente para usarlo en el contenedor.
# Luego, instala las dependencias del frontend con pnpm.
# Finalmente, compila el frontend de Next.js.
RUN npm install -g pnpm && \
    pnpm install && \
    pnpm build

# Expone el puerto 7777. Este es el puerto en el que Uvicorn escuchará dentro del contenedor.
EXPOSE 7777

# Define el comando que se ejecutará cuando el contenedor se inicie.
# Uvicorn servirá tu aplicación FastAPI (el objeto 'app' en 'playground.py')
# en todas las interfaces de red (0.0.0.0) y en el puerto 7777.
CMD ["uvicorn", "playground:app", "--host", "0.0.0.0", "--port", "7777"]