-- Add the password column to the users table
-- This allows the app to verify users based on their passwords without using Supabase Auth
ALTER TABLE public.users ADD COLUMN password TEXT;
