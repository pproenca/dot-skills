---
title: Test Components with URL State
impact: LOW-MEDIUM
impactDescription: enables reliable testing of nuqs-dependent components
tags: debug, testing, jest, vitest, react-testing-library
---

## Test Components with URL State

Test components that use nuqs by providing the NuqsTestingAdapter and controlling URL state in tests.

**Setup test adapter:**

```tsx
// test/utils.tsx
import { NuqsTestingAdapter } from 'nuqs/adapters/testing'
import { render, type RenderOptions } from '@testing-library/react'

export function renderWithNuqs(
  ui: React.ReactElement,
  { searchParams = {}, ...options }: RenderOptions & { searchParams?: Record<string, string> } = {}
) {
  return render(
    <NuqsTestingAdapter searchParams={searchParams}>
      {ui}
    </NuqsTestingAdapter>,
    options
  )
}
```

**Test with initial URL state:**

```tsx
// components/Pagination.test.tsx
import { screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { renderWithNuqs } from '@/test/utils'
import Pagination from './Pagination'

describe('Pagination', () => {
  it('displays current page from URL', () => {
    renderWithNuqs(<Pagination />, {
      searchParams: { page: '5' }
    })

    expect(screen.getByText('Page 5')).toBeInTheDocument()
  })

  it('updates page on click', async () => {
    renderWithNuqs(<Pagination />)

    await userEvent.click(screen.getByRole('button', { name: /next/i }))

    expect(screen.getByText('Page 2')).toBeInTheDocument()
  })
})
```

**Test URL updates:**

```tsx
import { NuqsTestingAdapter } from 'nuqs/adapters/testing'
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'

it('updates URL on state change', async () => {
  let capturedSearchParams = ''

  render(
    <NuqsTestingAdapter
      searchParams={{ page: '1' }}
      onUrlUpdate={({ searchParams }) => {
        capturedSearchParams = searchParams.toString()
      }}
    >
      <Pagination />
    </NuqsTestingAdapter>
  )

  await userEvent.click(screen.getByRole('button', { name: /next/i }))

  expect(capturedSearchParams).toBe('page=2')
})
```

**With server cache testing:**

```tsx
import { searchParamsCache } from '@/lib/searchParams'

it('parses search params on server', async () => {
  const params = { q: 'react', page: '3' }
  const { q, page } = await searchParamsCache.parse(Promise.resolve(params))

  expect(q).toBe('react')
  expect(page).toBe(3)
})
```

Reference: [nuqs Testing Adapter](https://nuqs.dev/docs/testing)
