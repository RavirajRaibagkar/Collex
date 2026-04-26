-- ==========================================
-- COLLEX - Sample Data Seed
-- Run this in the Supabase SQL Editor
-- This will create 3 mock users and 5 items
-- Password for all users is: password123
-- ==========================================

-- 1. Create Mock Users (auth.users)
-- We insert into auth.users first, because public.users has a foreign key to auth.users.
INSERT INTO auth.users (
  id, 
  instance_id, 
  aud, 
  role, 
  email, 
  encrypted_password,
  email_confirmed_at, 
  recovery_sent_at, 
  last_sign_in_at, 
  raw_app_meta_data, 
  raw_user_meta_data, 
  created_at, 
  updated_at, 
  confirmation_token, 
  email_change, 
  email_change_token_new, 
  recovery_token
)
VALUES
-- User 1: Raviraj
(
  '11111111-1111-1111-1111-111111111111', 
  '00000000-0000-0000-0000-000000000000', 
  'authenticated', 
  'authenticated', 
  'raviraj.raibagkar24@vit.edu', 
  crypt('password123', gen_salt('bf')), 
  current_timestamp, 
  null, 
  null, 
  '{"provider":"email","providers":["email"]}', 
  '{"name":"Raviraj Raibagkar"}', 
  current_timestamp, 
  current_timestamp, 
  '', '', '', ''
),
-- User 2: Jane
(
  '22222222-2222-2222-2222-222222222222', 
  '00000000-0000-0000-0000-000000000000', 
  'authenticated', 
  'authenticated', 
  'jane.doe@vit.edu', 
  crypt('password123', gen_salt('bf')), 
  current_timestamp, 
  null, 
  null, 
  '{"provider":"email","providers":["email"]}', 
  '{"name":"Jane Doe"}', 
  current_timestamp, 
  current_timestamp, 
  '', '', '', ''
),
-- User 3: John
(
  '33333333-3333-3333-3333-333333333333', 
  '00000000-0000-0000-0000-000000000000', 
  'authenticated', 
  'authenticated', 
  'john.smith@vit.edu', 
  crypt('password123', gen_salt('bf')), 
  current_timestamp, 
  null, 
  null, 
  '{"provider":"email","providers":["email"]}', 
  '{"name":"John Smith"}', 
  current_timestamp, 
  current_timestamp, 
  '', '', '', ''
) ON CONFLICT (id) DO NOTHING;

-- 2. Insert into public.users
INSERT INTO public.users (id, name, email, role, rating, rating_count)
VALUES 
('11111111-1111-1111-1111-111111111111', 'Raviraj Raibagkar', 'raviraj.raibagkar24@vit.edu', 'student', 4.5, 12),
('22222222-2222-2222-2222-222222222222', 'Jane Doe', 'jane.doe@vit.edu', 'student', 4.8, 5),
('33333333-3333-3333-3333-333333333333', 'John Smith', 'john.smith@vit.edu', 'student', 3.9, 8)
ON CONFLICT (id) DO NOTHING;

-- 3. Insert Sample Items
INSERT INTO public.items (seller_id, title, description, price, condition, category, is_sold, created_at)
VALUES
('22222222-2222-2222-2222-222222222222', 'Engineering Mathematics 1 & 2', 'Used first year textbooks, in good condition with minor highlights.', 450, 'Good', 'Books', false, current_timestamp),
('22222222-2222-2222-2222-222222222222', 'Mini Drafter', 'Omega brand mini drafter for ED class. Works perfectly.', 200, 'Good', 'Stationery', false, current_timestamp - interval '1 day'),
('33333333-3333-3333-3333-333333333333', 'Logitech Wireless Mouse', 'Barely used mouse, upgraded to a gaming one so giving this away.', 0, 'New', 'Electronics', false, current_timestamp - interval '2 days'),
('33333333-3333-3333-3333-333333333333', 'Lab Coat (Size M)', 'Clean lab coat required for chemistry practicals.', 150, 'Good', 'Clothing', false, current_timestamp - interval '3 hours'),
('22222222-2222-2222-2222-222222222222', 'Scientific Calculator Casio fx-991EX', 'A bit scratched but 100% functional, battery was replaced last month.', 600, 'Fair', 'Electronics', false, current_timestamp);
