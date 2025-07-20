# sv

Everything you need to build a Svelte project, powered by [`sv`](https://github.com/sveltejs/cli).

## Creating a project

If you're seeing this, you've probably already done this step. Congrats!

```bash
# create a new project in the current directory
npx sv create

# create a new project in my-app
npx sv create my-app
```

## Developing

Once you've created a project and installed dependencies with `npm install` (or `pnpm install` or `yarn`), start a development server:

```bash
npm run dev

# or start the server and open the app in a new browser tab
npm run dev -- --open
```

## Building

To create a production version of your app:

```bash
npm run build
```

You can preview the production build with `npm run preview`.

> To deploy your app, you may need to install an [adapter](https://svelte.dev/docs/kit/adapters) for your target environment.

## Laundry Management App

This is a web application for managing laundry services for hotels, built with SvelteKit and Supabase.

### Features

- Custom authentication with roles: Main Admin, Laundry Staff, Hotel Staff
- Order management
- User management (for admins)
- Reports generation and PDF export
- Notifications

## Setup

1. **Install dependencies:**

   ```bash
   npm install
   ```

2. **Set up Supabase:**
   - Create a Supabase project at https://supabase.com
   - Note your project URL and anon key
   - Create the following tables in your Supabase database:

     **users table:**
     - user_id: uuid (primary key, default gen_random_uuid())
     - email: text (unique)
     - password: text (hashed)
     - role: text (e.g., 'main_admin', 'laundry_staff', 'hotel_staff')

     **orders table:**
     - order_id: uuid (primary key, default gen_random_uuid())
     - user_id: uuid (foreign key to users)
     - hotel_name: text
     - items: jsonb (e.g., array of {type, quantity})
     - instructions: text
     - status: text (pending, in_process, completed, delivered)
     - created_at: timestamptz (default now())

     // Add more tables as needed, e.g., reports

3. **Environment variables:**
   Create a `.env` file in the root with:
   ```
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   JWT_SECRET=your_secret_key
   ```

## Running the App

```bash
npm run dev
```

Open http://localhost:5173 in your browser.

## Deployment

The app can be deployed to Vercel or Netlify using their SvelteKit adapters.

For Vercel: Install `@sveltejs/adapter-vercel` and update `svelte.config.js`.

Similar for Netlify.
