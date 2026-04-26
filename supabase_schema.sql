-- ================================================================
-- COLLEX - Supabase Database Schema
-- Run this in the Supabase SQL Editor
-- ================================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ================================================================
-- 1. USERS TABLE
-- ================================================================
CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL DEFAULT '',
  email TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'student',
  rating DECIMAL(3,1) NOT NULL DEFAULT 0.0,
  rating_count INTEGER NOT NULL DEFAULT 0,
  avatar_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- RLS
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view all profiles"
  ON public.users FOR SELECT USING (true);

CREATE POLICY "Users can insert own profile"
  ON public.users FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON public.users FOR UPDATE USING (auth.uid() = id);

-- ================================================================
-- 2. ITEMS TABLE
-- ================================================================
CREATE TABLE IF NOT EXISTS public.items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  description TEXT,
  price DECIMAL(10,2) NOT NULL DEFAULT 0,
  category TEXT NOT NULL DEFAULT 'Others',
  condition TEXT NOT NULL DEFAULT 'Good',
  image_url TEXT,
  seller_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  is_sold BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- RLS
ALTER TABLE public.items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view available items"
  ON public.items FOR SELECT USING (true);

CREATE POLICY "Authenticated users can post items"
  ON public.items FOR INSERT WITH CHECK (auth.uid() = seller_id);

CREATE POLICY "Sellers can update own items"
  ON public.items FOR UPDATE USING (auth.uid() = seller_id);

CREATE POLICY "Sellers can delete own items"
  ON public.items FOR DELETE USING (auth.uid() = seller_id);

-- Index for performance
CREATE INDEX IF NOT EXISTS items_seller_id_idx ON public.items(seller_id);
CREATE INDEX IF NOT EXISTS items_category_idx ON public.items(category);
CREATE INDEX IF NOT EXISTS items_created_at_idx ON public.items(created_at DESC);

-- ================================================================
-- 3. REQUESTS TABLE
-- ================================================================
CREATE TABLE IF NOT EXISTS public.requests (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  item_id UUID NOT NULL REFERENCES public.items(id) ON DELETE CASCADE,
  requester_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'pending', -- pending | accepted | rejected
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(item_id, requester_id)
);

-- RLS
ALTER TABLE public.requests ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own requests"
  ON public.requests FOR SELECT USING (
    auth.uid() = requester_id
    OR auth.uid() IN (
      SELECT seller_id FROM public.items WHERE id = requests.item_id
    )
  );

CREATE POLICY "Authenticated users can create requests"
  ON public.requests FOR INSERT WITH CHECK (auth.uid() = requester_id);

CREATE POLICY "Item sellers can update request status"
  ON public.requests FOR UPDATE USING (
    auth.uid() IN (
      SELECT seller_id FROM public.items WHERE id = requests.item_id
    )
  );

-- ================================================================
-- 4. MESSAGES TABLE
-- ================================================================
CREATE TABLE IF NOT EXISTS public.messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sender_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  receiver_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  message TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- RLS
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own messages"
  ON public.messages FOR SELECT USING (
    auth.uid() = sender_id OR auth.uid() = receiver_id
  );

CREATE POLICY "Authenticated users can send messages"
  ON public.messages FOR INSERT WITH CHECK (auth.uid() = sender_id);

-- Index for real-time chat performance
CREATE INDEX IF NOT EXISTS messages_sender_receiver_idx
  ON public.messages(sender_id, receiver_id);
CREATE INDEX IF NOT EXISTS messages_created_at_idx
  ON public.messages(created_at ASC);

-- Enable Realtime for messages
ALTER PUBLICATION supabase_realtime ADD TABLE public.messages;

-- ================================================================
-- 5. STORAGE BUCKET
-- ================================================================

-- Create the item-images bucket (run via Supabase dashboard or API)
-- Go to: Storage → Create Bucket → Name: "item-images" → Public: true

-- Storage policies (after creating bucket):
INSERT INTO storage.buckets (id, name, public)
VALUES ('item-images', 'item-images', true)
ON CONFLICT (id) DO NOTHING;

CREATE POLICY "Anyone can view item images"
  ON storage.objects FOR SELECT USING (bucket_id = 'item-images');

CREATE POLICY "Authenticated users can upload item images"
  ON storage.objects FOR INSERT WITH CHECK (
    bucket_id = 'item-images' AND auth.role() = 'authenticated'
  );

CREATE POLICY "Users can delete own item images"
  ON storage.objects FOR DELETE USING (
    bucket_id = 'item-images' AND auth.uid()::text = (storage.foldername(name))[1]
  );
