---
title: Avoid Side Effects
impact: HIGH
impactDescription: prevents hidden temporal couplings
tags: func, side-effects, purity, predictability
---

## Avoid Side Effects

Side effects are lies. Your function promises to do one thing, but it also does other hidden things. Avoid unexpected changes to class variables, globals, or passed arguments.

**Incorrect (hidden side effect):**

```java
public class UserValidator {
    private Cryptographer cryptographer;
    private Session session;

    public boolean checkPassword(String userName, String password) {
        User user = UserGateway.findByName(userName);
        if (user != null) {
            String codedPhrase = user.getPhraseEncodedByPassword();
            String phrase = cryptographer.decrypt(codedPhrase, password);
            if ("Valid Password".equals(phrase)) {
                session.initialize();  // Hidden side effect!
                return true;
            }
        }
        return false;
    }
}
// Calling checkPassword twice destroys the session unexpectedly
```

**Correct (explicit behavior):**

```java
public class UserValidator {
    private Cryptographer cryptographer;

    public boolean checkPassword(String userName, String password) {
        User user = UserGateway.findByName(userName);
        if (user == null) return false;

        String codedPhrase = user.getPhraseEncodedByPassword();
        String phrase = cryptographer.decrypt(codedPhrase, password);
        return "Valid Password".equals(phrase);
    }
}

// Separate function with clear name
public class SessionManager {
    public void initializeSessionForUser(String userName, String password) {
        if (userValidator.checkPassword(userName, password)) {
            session.initialize();
        }
    }
}
```

If you must have a temporal coupling, make it explicit in the function name: `checkPasswordAndInitializeSession`.

Reference: [Clean Code, Chapter 3: Functions](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
