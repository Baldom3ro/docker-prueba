# ==========================================
# Etapa 1: Compilación con Node.js
# ==========================================
FROM node:22-alpine AS build

WORKDIR /app

# Copiar definiciones de dependencias
COPY package*.json ./

# Instalar dependencias
RUN npm install

# Copiar código fuente
COPY . .

# Compilar proyecto web (genera carpeta www)
RUN npm run build

# ==========================================
# Etapa 2: Servidor Web con Nginx
# ==========================================
FROM nginx:alpine

# Copiar archivos compilados desde la etapa de build hacia Nginx
COPY --from=build /app/www /usr/share/nginx/html

# Exponer puerto 80 del contenedor
EXPOSE 80

# Iniciar Nginx en primer plano
CMD ["nginx", "-g", "daemon off;"]