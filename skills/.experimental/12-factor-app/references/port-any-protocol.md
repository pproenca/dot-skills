---
title: Use Port Binding to Export Any Protocol Not Just HTTP
impact: MEDIUM
impactDescription: enables microservices to be backing services for each other
tags: port, protocols, services, microservices
---

## Use Port Binding to Export Any Protocol Not Just HTTP

The port-binding pattern applies to any protocol, not just HTTP. Applications can export services via SMTP, Redis protocol, gRPC, WebSocket, or any custom protocol. This enables one twelve-factor app to serve as a backing service for another.

**Incorrect (protocol-specific deployment requirements):**

```python
# gRPC service requiring special server injection
# Assumes specific infrastructure for gRPC routing
class UserService:
    def GetUser(self, request):
        return User(id=request.id)

# Deployed via gRPC-specific server manager
# Can't use same deployment model as HTTP services
# Requires different infrastructure per protocol
```

**Correct (all protocols via port binding):**

```python
# gRPC service self-contained with port binding
import grpc
from concurrent import futures
import os

class UserService(user_pb2_grpc.UserServiceServicer):
    def GetUser(self, request, context):
        return user_pb2.User(id=request.id, name="Alice")

def serve():
    port = os.environ.get('PORT', '50051')
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
    user_pb2_grpc.add_UserServiceServicer_to_server(UserService(), server)
    server.add_insecure_port(f'[::]:{port}')
    server.start()
    server.wait_for_termination()
# Same deployment model as HTTP - container binds to PORT
```

**HTTP service (common case):

```python
# HTTP API service
from flask import Flask
app = Flask(__name__)

@app.route('/api/users/<id>')
def get_user(id):
    return {"id": id, "name": "Alice"}

# Bind to port
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=int(os.environ.get('PORT', 8080)))
```

**gRPC service:**

```python
# gRPC service on port
import grpc
from concurrent import futures
import user_pb2_grpc

class UserService(user_pb2_grpc.UserServiceServicer):
    def GetUser(self, request, context):
        return user_pb2.User(id=request.id, name="Alice")

def serve():
    port = os.environ.get('PORT', '50051')
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
    user_pb2_grpc.add_UserServiceServicer_to_server(UserService(), server)
    server.add_insecure_port(f'[::]:{port}')
    server.start()
    server.wait_for_termination()
```

**WebSocket service:**

```python
import asyncio
import websockets
import os

async def handler(websocket, path):
    async for message in websocket:
        await websocket.send(f"Echo: {message}")

async def main():
    port = int(os.environ.get('PORT', 8765))
    async with websockets.serve(handler, "0.0.0.0", port):
        await asyncio.Future()  # Run forever

asyncio.run(main())
```

**One app as backing service for another:**

```yaml
# docker-compose.yml
services:
  # User service exposes gRPC
  user-service:
    build: ./user-service
    environment:
      - PORT=50051
      - DATABASE_URL=postgresql://db:5432/users

  # API gateway consumes user service
  api-gateway:
    build: ./api-gateway
    environment:
      - PORT=8080
      - USER_SERVICE_URL=grpc://user-service:50051
    depends_on:
      - user-service
```

```python
# API gateway consuming user service
USER_SERVICE_URL = os.environ['USER_SERVICE_URL']  # grpc://user-service:50051
# User service is an attached resource, just like a database
# Can swap implementations without changing API gateway code
```

**Benefits:**
- Microservices can be backing services for each other
- Service mesh handles routing regardless of protocol
- Same deployment model for HTTP, gRPC, WebSocket, etc.
- Easy to swap service implementations

Reference: [The Twelve-Factor App - Port Binding](https://12factor.net/port-binding)
