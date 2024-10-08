# Hello World Wide Web
|||
-|-
Authors | Clayton, Jozef

## Setup
You can use Docker to run the app locally.

1. [Download Docker Desktop](https://docs.docker.com/get-docker/) if you do not already have it.
1. Open Docker Desktop.

You can use the [`docker compose`](https://docs.docker.com/compose/reference/) command to start and stop the app.

1. Navigate into the app folder in this repository.
   ```
   cd HelloWorldWideWeb
   ```
1. To start the app:
   ```
   docker compose up -d --build
   ```
1. Go to <http://localhost:8080/> to see the app.
1. To stop the app:
   ```
   docker compose down
   ```

You can also quit Docker Desktop to stop the app.
