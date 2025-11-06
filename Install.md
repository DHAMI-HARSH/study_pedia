# Installation Guide - Referral & Credit System Monorepo

## Prerequisites

- Node.js 18+ and npm/yarn/pnpm
- Git

## Quick Start

### 1. Install Dependencies

Using pnpm (recommended for monorepo):
\`\`\`bash
pnpm install
\`\`\`

Or using npm:
\`\`\`bash
npm install
\`\`\`

Or using yarn:
\`\`\`bash
yarn install
\`\`\`

### 2. All Required Libraries by Package

#### Root Dependencies (Build & Orchestration)
- **turbo** ^2.0.0 - Monorepo task orchestration and caching

#### Web App (`apps/web`) Dependencies

**Runtime:**
- **next** ^16.0.0 - React framework with App Router
- **react** ^19.2.0 - React library
- **react-dom** ^19.2.0 - React DOM rendering
- **zustand** ^5.0.0 - Lightweight state management
- **framer-motion** ^12.0.0 - Animation library for smooth UI interactions
- **swr** ^2.2.0 - Data fetching with caching and revalidation
- **@supabase/ssr** ^0.7.0 - Supabase server-side rendering utilities
- **@supabase/supabase-js** ^2.45.0 - Supabase client library
- **tailwindcss** ^4.0.0 - Utility-first CSS framework

**Development:**
- **typescript** ^5.3.0 - TypeScript compiler
- **@types/react** ^19.0.0 - React type definitions
- **@types/react-dom** ^19.0.0 - React DOM type definitions
- **@types/node** ^20.10.0 - Node.js type definitions
- **autoprefixer** ^10.4.0 - PostCSS plugin for vendor prefixes
- **postcss** ^8.4.0 - CSS transformation framework

#### API Server (`apps/api`) Dependencies

**Runtime:**
- **express** ^4.18.0 - Web framework for REST API
- **cors** ^2.8.0 - Cross-Origin Resource Sharing middleware
- **@supabase/supabase-js** ^2.45.0 - Supabase admin client
- **zod** ^3.22.0 - TypeScript-first schema validation
- **jsonwebtoken** ^9.1.0 - JWT token signing and verification
- **dotenv** ^16.3.0 - Environment variable management

**Development:**
- **typescript** ^5.3.0 - TypeScript compiler
- **@types/express** ^4.17.0 - Express type definitions
- **@types/node** ^20.10.0 - Node.js type definitions
- **@types/jsonwebtoken** ^9.0.5 - JWT type definitions
- **@types/cors** ^2.8.17 - CORS type definitions
- **tsx** ^4.7.0 - TypeScript executor for Node.js

#### Shared Package (`packages/shared`) Dependencies

**Runtime:**
- **zod** ^3.22.0 - Schema validation

**Development:**
- **typescript** ^5.3.0 - TypeScript compiler

### 3. Install Everything at Once

\`\`\`bash
# From root directory
pnpm install

# Verify installation
pnpm type-check
\`\`\`

### 4. Environment Variables

Create `.env.local` files in each app:

**`apps/web/.env.local`:**
\`\`\`
NEXT_PUBLIC_SUPABASE_URL=your_supabase_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
NEXT_PUBLIC_API_URL=http://localhost:3001
\`\`\`

**`apps/api/.env`:**
\`\`\`
SUPABASE_URL=your_supabase_url
SUPABASE_SERVICE_ROLE_KEY=your_supabase_service_key
JWT_SECRET=your_jwt_secret
PORT=3001
NODE_ENV=development
\`\`\`

### 5. Run Development Servers

From root directory:
\`\`\`bash
# Run all services in parallel
pnpm dev

# Or run individually
cd apps/web && pnpm dev      # Next.js on localhost:3000
cd apps/api && pnpm dev      # Express on localhost:3001
\`\`\`

### 6. Build for Production

\`\`\`bash
pnpm build
\`\`\`

## Dependency Breakdown by Feature

### UI & Animation
- `framer-motion` - Smooth animations and transitions
- `tailwindcss` - Styling
- `next` - UI framework

### State Management & Data
- `zustand` - Client-side state (auth, credits, referrals)
- `swr` - Data fetching and cache management
- `@supabase/ssr` - Server-side auth handling

### Backend & API
- `express` - REST API server
- `cors` - Cross-origin requests
- `zod` - Input validation

### Database
- `@supabase/supabase-js` - Database and auth client (both web and API)

### Authentication
- `jsonwebtoken` - JWT handling for API auth
- `@supabase/ssr` - Session management

### Development Tools
- `typescript` - Type safety
- `tsx` - Run TypeScript files directly in Node
- `postcss` + `autoprefixer` - CSS processing

## Troubleshooting

### Port Conflicts
- Web: Change `pnpm dev` port with `--port 3001`
- API: Change `PORT` env variable

### Missing Dependencies
\`\`\`bash
# Reinstall all dependencies
pnpm clean && pnpm install
\`\`\`

### Type Errors
\`\`\`bash
pnpm type-check
\`\`\`

## Next Steps

1. Configure Supabase (see `SETUP.md`)
2. Run database migrations (see `apps/api/scripts/`)
3. Start development with `pnpm dev`
4. Deploy to Vercel (web) and Railway/Render (API)
