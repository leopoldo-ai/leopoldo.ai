# Spec Card: vitest-testing

## Identity
- **Pack:** full-stack
- **Sub-pack:** frontend
- **Layer:** userland

## Scope
Modern unit and component testing with Vitest. Covers setup, configuration, mocking, snapshot testing, coverage, and React/Next.js component testing with Testing Library. OSS-first: Vitest is the standard, Jest as "aware of" legacy fallback.

Does NOT cover: E2E testing (covered by e2e-testing-patterns), Storybook testing (covered by storybook-patterns), or security testing (covered by security sub-pack).

## Expected Inputs
- User asks to write tests, set up testing, or configure Vitest
- User mentions unit tests, component tests, mocking, coverage
- User migrating from Jest to Vitest

## Expected Outputs
- Vitest configuration for React/Next.js projects
- Test patterns: unit, component, integration
- Mocking patterns: modules, APIs, timers, browser APIs
- Coverage configuration and reporting
- CI integration for test runs

## Must-Have Features
1. Vitest setup for Next.js App Router (with vitest.config.ts)
2. React Testing Library integration (@testing-library/react)
3. Component testing patterns (render, query, fireEvent, userEvent)
4. Mocking: vi.mock, vi.fn, vi.spyOn, MSW for API mocking
5. Snapshot testing (inline and file-based)
6. Coverage with v8 provider and threshold configuration
7. Watch mode and filtering patterns
8. TypeScript support (no extra config needed)

## Nice-to-Have Features
1. Jest migration guide (jest.fn -> vi.fn, etc.)
2. Parallel test execution optimization
3. Browser mode testing
4. Custom matchers with expect.extend

## Anti-Patterns
- Using Jest in new projects (Vitest is faster, native ESM)
- Testing implementation details instead of behavior
- Mocking everything (test real integrations where possible)
- Snapshot-heavy test suites without meaningful assertions

## Integration Points
- `e2e-testing-patterns`: Complementary (unit vs E2E)
- `storybook-patterns`: Storybook Vitest addon
- `nextjs-developer`: Next.js specific test patterns
- `react-best-practices`: Testing performance patterns

## Success Criteria
- Vitest runs in under 2 seconds for a typical component test suite
- Can test Server Components and Client Components
- Coverage reporting works in CI (GitHub Actions)
- Mocking patterns cover: modules, fetch, timers, env vars

## Key Rules
- Vitest is ALWAYS recommended over Jest for new projects
- Use @testing-library/react, never enzyme
- Test behavior, not implementation
- MSW for API mocking, not manual fetch mocks
- Coverage thresholds: 80% minimum recommended
