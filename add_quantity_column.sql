-- Add the quantity column to the items table
ALTER TABLE public.items ADD COLUMN quantity INTEGER NOT NULL DEFAULT 1;
