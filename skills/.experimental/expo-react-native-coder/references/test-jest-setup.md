---
title: Configure Jest with jest-expo Preset
impact: MEDIUM
impactDescription: reduces test setup from hours to minutes
tags: test, jest, unit-testing, configuration
---

## Configure Jest with jest-expo Preset

Use `jest-expo` preset to automatically mock native modules and configure the testing environment.

**Incorrect (manual mocking of native modules):**

```javascript
// jest.config.js - Manual setup is complex and incomplete
module.exports = {
  preset: 'react-native',
  moduleNameMapper: {
    'expo-secure-store': '<rootDir>/__mocks__/expo-secure-store.js',
    'expo-haptics': '<rootDir>/__mocks__/expo-haptics.js',
    // 50+ more manual mocks needed...
  },
};
// Tests fail with "Cannot find native module" errors
```

**Correct (jest-expo preset handles mocking):**

```bash
npx expo install jest-expo jest @types/jest
```

```javascript
// jest.config.js
module.exports = {
  preset: 'jest-expo',
  setupFilesAfterEnv: ['<rootDir>/jest.setup.js'],
  transformIgnorePatterns: [
    'node_modules/(?!((jest-)?react-native|@react-native(-community)?)|expo(nent)?|@expo(nent)?/.*|react-navigation|@react-navigation/.*)',
  ],
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/$1',
  },
};
```

```javascript
// jest.setup.js
import '@testing-library/jest-native/extend-expect';

jest.mock('expo-router', () => ({
  useRouter: () => ({ push: jest.fn(), replace: jest.fn(), back: jest.fn() }),
  useLocalSearchParams: () => ({}),
  Link: ({ children }) => children,
}));
```

```json
{
  "scripts": {
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage"
  }
}
```

Reference: [Unit testing with Jest - Expo Documentation](https://docs.expo.dev/develop/unit-testing/)
