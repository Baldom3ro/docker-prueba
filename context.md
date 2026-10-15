# Guía de Práctica: Ionic Web con Docker y GitHub

Esta guía contiene el procedimiento paso a paso para personalizar la aplicación Ionic, subirla al repositorio remoto en GitHub, compilarla, contenerizarla con Docker (Node + Nginx) y verificar su ejecución en navegador.

---

## Índice de Pasos
1. [Paso 1: Personalizar contenido de la aplicación Ionic](#paso-1-personalizar-contenido-de-la-aplicación-ionic)
2. [Paso 2: Subir proyecto a repositorio GitHub](#paso-2-subir-proyecto-a-repositorio-github)
3. [Paso 3: Crear Dockerfile y .dockerignore](#paso-3-crear-dockerfile-y-dockerignore)
4. [Paso 4: Compilación de la aplicación Ionic](#paso-4-compilación-de-la-aplicación-ionic)
5. [Paso 5: Construcción de imagen Docker](#paso-5-construcción-de-imagen-docker)
6. [Paso 6: Despliegue del contenedor Docker](#paso-6-despliegue-del-contenedor-docker)
7. [Paso 7: Inspección y lectura de logs](#paso-7-inspección-y-lectura-de-logs)
8. [Paso 8: Verificación en navegador web](#paso-8-verificación-en-navegador-web)
9. [Paso 9: Detención y reinicio del contenedor](#paso-9-detención-y-reinicio-del-contenedor)
10. [Paso 10: Sincronización final con GitHub](#paso-10-sincronización-final-con-github)

---

## Paso 1: Personalizar contenido de la aplicación Ionic

Para cumplir con el requerimiento de mostrar contenido personalizado de la aplicación:

1. Abrir archivo principal de vista en `src/app/home/home.page.html` (o `src/index.html` según estructura del proyecto).
2. Modificar título (`<ion-title>`) y textos en `<ion-content>`.
   - Ejemplo de contenido:
     - Título: `Práctica Docker - Ionic Web`
     - Subtítulo/Texto: Nombre del alumno, matrícula o descripción de la práctica.
3. Guardar cambios.

---

## Paso 2: Subir proyecto a repositorio GitHub

> **Nota:** Este paso se realiza primero conforme a las instrucciones.

1. Abrir terminal en la raíz de la carpeta `docker-prueba`.
2. Verificar estado de Git:
   ```bash
   git status
   ```
3. Vincular repositorio remoto de GitHub:
   ```bash
   git remote add origin https://github.com/Baldom3ro/docker-prueba.git
   ```
4. Asegurar rama principal `main`:
   ```bash
   git branch -M main
   ```
5. Registrar cambios y realizar commit inicial:
   ```bash
   git add .
   git commit -m "feat: configuracion inicial proyecto ionic"
   ```
6. Enviar código a GitHub:
   ```bash
   git push -u origin main
   ```
7. *(Opcional)* Tomar captura de pantalla de la terminal confirmando el `git push` exitoso y del repositorio en navegador.

---

## Paso 3: Crear Dockerfile y .dockerignore

Para compilar con Node y publicar con Nginx, se utiliza una construcción multi-etapa (*multi-stage build*).

### 3.1 Crear archivo `Dockerfile`
Crear archivo llamado exactamente `Dockerfile` (sin extensión) en la raíz de `docker-prueba`:

```dockerfile
# ==========================================
# Etapa 1: Compilación con Node.js
# ==========================================
FROM node:20-alpine AS build

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
```

> **Variante alternativa con build previo local:**
> Si la maestra solicita compilar primero en local con `ionic build` y luego empaquetar directo en Nginx:
> ```dockerfile
> FROM nginx:alpine
> COPY www /usr/share/nginx/html
> EXPOSE 80
> CMD ["nginx", "-g", "daemon off;"]
> ```

### 3.2 Crear archivo `.dockerignore`
Crear archivo `.dockerignore` en la raíz para evitar enviar archivos pesados innecesarios al contexto de Docker:

```text
node_modules
www
.git
.vscode
.editorconfig
```

---

## Paso 4: Compilación de la aplicación Ionic

Ejecutar comando de compilación local para verificar que no existan errores de TypeScript o plantillas:

```bash
ionic build
```
*(o alternativamente: `npm run build`)*

> 📸 **PUNTO DE CAPTURA:** Tomar captura de pantalla de la terminal mostrando la finalización exitosa de `ionic build`.

---

## Paso 5: Construcción de imagen Docker

Construir imagen Docker con la etiqueta `docker-prueba`:

```bash
docker build -t docker-prueba .
```

> 📸 **PUNTO DE CAPTURA:** Tomar captura de pantalla del proceso de construcción terminando en `Successfully tagged docker-prueba:latest` o exportación de capas completada.

---

## Paso 6: Despliegue del contenedor Docker

Iniciar contenedor en segundo plano (`-d`), mapeando el puerto `8080` de la máquina anfitriona al puerto `80` del contenedor:

```bash
docker run -d --name "ionic web" -p 8080:80 docker-prueba
```

*Nota:* Si tu shell presenta inconvenientes con espacios en el nombre, usar:
```bash
docker run -d --name ionicweb -p 8080:80 docker-prueba
```

---

## Paso 7: Inspección y lectura de logs

1. Listar contenedores activos para comprobar estado `Up`:
   ```bash
   docker ps
   ```

2. Consultar logs generados por el servidor web Nginx dentro del contenedor:
   ```bash
   docker logs "ionic web"
   ```
   *(o `docker logs ionicweb` si se usó sin espacio)*

---

## Paso 8: Verificación en navegador web

1. Abrir navegador web (Chrome, Edge o Firefox).
2. Ingresar a la URL:
   ```text
   http://localhost:8080
   ```
3. Confirmar que cargue la aplicación Ionic:
   - Verificar título visible.
   - Confirmar contenido personalizado definido en el Paso 1.
4. Recargar la página (`F5` o `Ctrl + R`) para asegurar respuesta correcta de Nginx.
5. Presionar `F12` para abrir consola de desarrollador y verificar que no existan errores 404 o scripts fallidos.
6. Volver a revisar logs en la terminal para observar peticiones HTTP registradas:
   ```bash
   docker logs "ionic web"
   ```

> 📸 **PUNTO DE CAPTURA:** Tomar captura de pantalla completa del navegador mostrando la app en `http://localhost:8080` con el contenido personalizado.

---

## Paso 9: Detención y reinicio del contenedor

Demostrar control del ciclo de vida del contenedor:

1. Detener contenedor:
   ```bash
   docker stop "ionic web"
   ```
2. Verificar que ya no aparezca en ejecución:
   ```bash
   docker ps
   ```
3. Volver a iniciar contenedor:
   ```bash
   docker start "ionic web"
   ```
4. Confirmar que vuelve a estar activo:
   ```bash
   docker ps
   ```
5. Comprobar nuevamente acceso en `http://localhost:8080`.

---

## Paso 10: Sincronización final con GitHub

Subir los nuevos archivos (`Dockerfile`, `.dockerignore`, `context.md` y cambios de contenido):

```bash
git add .
git commit -m "feat: dockerfile nginx y guia completada"
git push origin main
```
