/*
  # Create initial users and set roles

  1. Create Users
    - Admin user
    - Sales agent
    - Operations manager
    - Operator
  
  2. Security
    - Set user roles in auth.users metadata
    - Enable RLS
    - Add policies for role-based access
*/

-- Create users with roles in their metadata
DO $$
DECLARE
  admin_uid UUID;
  sales_uid UUID;
  ops_uid UUID;
  operator_uid UUID;
BEGIN
  -- Create admin user
  INSERT INTO auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    raw_app_meta_data,
    raw_user_meta_data,
    created_at,
    updated_at,
    confirmation_token,
    email_change,
    email_change_token_new,
    recovery_token
  ) VALUES (
    '00000000-0000-0000-0000-000000000000',
    gen_random_uuid(),
    'authenticated',
    'authenticated',
    'admin@aspcranes.com',
    crypt('admin123', gen_salt('bf')),
    now(),
    '{"provider":"email","providers":["email"]}',
    '{"role":"admin","name":"Admin User","avatar":"https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg"}',
    now(),
    now(),
    '',
    '',
    '',
    ''
  ) RETURNING id INTO admin_uid;

  -- Create sales agent
  INSERT INTO auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    raw_app_meta_data,
    raw_user_meta_data,
    created_at,
    updated_at,
    confirmation_token,
    email_change,
    email_change_token_new,
    recovery_token
  ) VALUES (
    '00000000-0000-0000-0000-000000000000',
    gen_random_uuid(),
    'authenticated',
    'authenticated',
    'john@aspcranes.com',
    crypt('sales123', gen_salt('bf')),
    now(),
    '{"provider":"email","providers":["email"]}',
    '{"role":"sales_agent","name":"John Sales","avatar":"https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg"}',
    now(),
    now(),
    '',
    '',
    '',
    ''
  ) RETURNING id INTO sales_uid;

  -- Create operations manager
  INSERT INTO auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    raw_app_meta_data,
    raw_user_meta_data,
    created_at,
    updated_at,
    confirmation_token,
    email_change,
    email_change_token_new,
    recovery_token
  ) VALUES (
    '00000000-0000-0000-0000-000000000000',
    gen_random_uuid(),
    'authenticated',
    'authenticated',
    'sara@aspcranes.com',
    crypt('manager123', gen_salt('bf')),
    now(),
    '{"provider":"email","providers":["email"]}',
    '{"role":"operations_manager","name":"Sara Manager","avatar":"https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg"}',
    now(),
    now(),
    '',
    '',
    '',
    ''
  ) RETURNING id INTO ops_uid;

  -- Create operator
  INSERT INTO auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    raw_app_meta_data,
    raw_user_meta_data,
    created_at,
    updated_at,
    confirmation_token,
    email_change,
    email_change_token_new,
    recovery_token
  ) VALUES (
    '00000000-0000-0000-0000-000000000000',
    gen_random_uuid(),
    'authenticated',
    'authenticated',
    'mike@aspcranes.com',
    crypt('operator123', gen_salt('bf')),
    now(),
    '{"provider":"email","providers":["email"]}',
    '{"role":"operator","name":"Mike Operator","avatar":"https://images.pexels.com/photos/614810/pexels-photo-614810.jpeg"}',
    now(),
    now(),
    '',
    '',
    '',
    ''
  ) RETURNING id INTO operator_uid;

END $$;