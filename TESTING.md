# LSAT Writing App Browser Verification

## START HERE
All browser testing lives inside this repo and runs against the static `index.html` app.

## Install once
```bash
cd /Users/kerriannlark/Documents/Playground/GitHub/LSAT-WRITING-OS
npm install
npm run install:browsers
```

## Run tests
### Core interactive smoke
```bash
npm run test:smoke
```

### Full suite
```bash
npm run test:all
```

### Headed Chromium debug run
```bash
npm run test:headed
```

## Open the HTML report
```bash
npx playwright show-report playwright-report
```

## What gets tested
- interactive practice launch, prompt switching, timers, reset, highlights, editor tools, persistence
- course modules, builders, timers, and tracker persistence

## Common triage
1. **Port already in use**
   - close the old local server, then rerun tests
2. **Browser missing**
   - run `npm run install:browsers`
3. **Old cached app behavior**
   - tests block service workers, so rerun locally before debugging cache issues
4. **A selector broke after UI changes**
   - update the test and, if needed, add a small `data-testid` hook in `index.html`
