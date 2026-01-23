---
title: Web Framework Concerns Stay in Interface Layer
impact: MEDIUM
impactDescription: enables delivery mechanism substitution
tags: frame, web, http, interface
---

## Web Framework Concerns Stay in Interface Layer

HTTP-specific code (requests, responses, headers, cookies, sessions) belongs in the interface adapters layer. Use cases should be callable from any delivery mechanism.

**Incorrect (use case coupled to HTTP):**

```typescript
// application/usecases/LoginUseCase.ts
import { Request, Response } from 'express'
import { sign } from 'jsonwebtoken'

export class LoginUseCase {
  async execute(req: Request, res: Response) {
    const { email, password } = req.body

    const user = await this.users.findByEmail(email)
    if (!user || !user.verifyPassword(password)) {
      return res.status(401).json({ error: 'Invalid credentials' })
    }

    // Set HTTP-only cookie
    const token = sign({ userId: user.id }, process.env.JWT_SECRET)
    res.cookie('auth_token', token, {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'strict'
    })

    return res.json({ user: { id: user.id, email: user.email } })
  }
}

// Cannot call from CLI, message queue, or test without Express
```

**Correct (use case independent of delivery):**

```typescript
// application/usecases/LoginUseCase.ts
export interface LoginCommand {
  email: string
  password: string
}

export interface LoginResult {
  userId: string
  email: string
  authToken: string
}

export class LoginUseCase {
  constructor(
    private users: UserRepository,
    private tokenService: TokenService
  ) {}

  async execute(command: LoginCommand): Promise<LoginResult> {
    const user = await this.users.findByEmail(command.email)

    if (!user) {
      throw new InvalidCredentialsError()
    }

    if (!user.verifyPassword(command.password)) {
      throw new InvalidCredentialsError()
    }

    const token = this.tokenService.generate({ userId: user.id.value })

    return {
      userId: user.id.value,
      email: user.email.value,
      authToken: token
    }
  }
}

// interface/http/AuthController.ts
import { Request, Response } from 'express'

export class AuthController {
  constructor(private loginUseCase: LoginUseCase) {}

  async login(req: Request, res: Response) {
    try {
      const result = await this.loginUseCase.execute({
        email: req.body.email,
        password: req.body.password
      })

      // HTTP concerns in controller
      res.cookie('auth_token', result.authToken, {
        httpOnly: true,
        secure: process.env.NODE_ENV === 'production',
        sameSite: 'strict'
      })

      return res.json({
        user: { id: result.userId, email: result.email }
      })
    } catch (error) {
      if (error instanceof InvalidCredentialsError) {
        return res.status(401).json({ error: 'Invalid credentials' })
      }
      throw error
    }
  }
}

// interface/cli/AuthCli.ts - Same use case, different delivery
export class AuthCli {
  async login(email: string, password: string) {
    const result = await this.loginUseCase.execute({ email, password })
    console.log(`Logged in as ${result.email}`)
    fs.writeFileSync('.auth_token', result.authToken)
  }
}
```

**Benefits:**
- Same use case for HTTP, CLI, WebSocket, queue consumers
- Easy to test without HTTP mocking
- Web framework upgrades isolated to interface layer

Reference: [Clean Architecture - The Web is a Detail](https://www.oreilly.com/library/view/clean-architecture-a/9780134494272/ch31.xhtml)
