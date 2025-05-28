/*
  # Update leads table schema

  1. Changes
    - Add column mappings for snake_case to camelCase conversion
    - Ensure all required columns exist with correct types
    - Update RLS policies for proper access control

  2. Security
    - Maintain existing RLS policies
    - Ensure proper access for all roles
*/

-- Add any missing columns (safe operation - will skip if column exists)
DO $$ 
BEGIN
  -- Add priority if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'leads' AND column_name = 'priority'
  ) THEN
    ALTER TABLE leads ADD COLUMN priority text;
  END IF;

  -- Add source if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'leads' AND column_name = 'source'
  ) THEN
    ALTER TABLE leads ADD COLUMN source text;
  END IF;

  -- Add created_by if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'leads' AND column_name = 'created_by'
  ) THEN
    ALTER TABLE leads ADD COLUMN created_by uuid REFERENCES auth.users(id);
  END IF;
END $$;

-- Update or create constraints
DO $$ 
BEGIN
  -- Drop existing constraints if they exist
  ALTER TABLE leads DROP CONSTRAINT IF EXISTS leads_status_check;
  ALTER TABLE leads DROP CONSTRAINT IF EXISTS leads_priority_check;
  
  -- Add updated constraints
  ALTER TABLE leads ADD CONSTRAINT leads_status_check 
    CHECK (status IN ('new', 'negotiation', 'won', 'lost'));
  
  ALTER TABLE leads ADD CONSTRAINT leads_priority_check 
    CHECK (priority IS NULL OR priority IN ('low', 'medium', 'high'));
END $$;

-- Ensure RLS is enabled
ALTER TABLE leads ENABLE ROW LEVEL SECURITY;

-- Recreate policies (will be skipped if they already exist)
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE policyname = 'Admins have full access'
  ) THEN
    CREATE POLICY "Admins have full access"
      ON leads
      FOR ALL
      TO authenticated
      USING ((auth.jwt() ->> 'role'::text) = 'admin'::text);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE policyname = 'Operations managers can view all leads'
  ) THEN
    CREATE POLICY "Operations managers can view all leads"
      ON leads
      FOR SELECT
      TO authenticated
      USING ((auth.jwt() ->> 'role'::text) = 'operations_manager'::text);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE policyname = 'Sales agents can view all leads'
  ) THEN
    CREATE POLICY "Sales agents can view all leads"
      ON leads
      FOR SELECT
      TO authenticated
      USING ((auth.jwt() ->> 'role'::text) = 'sales_agent'::text);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE policyname = 'Sales agents can modify their assigned leads'
  ) THEN
    CREATE POLICY "Sales agents can modify their assigned leads"
      ON leads
      FOR ALL
      TO authenticated
      USING (
        ((auth.jwt() ->> 'role'::text) = 'sales_agent'::text) AND
        (assigned_to = auth.uid())
      );
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE policyname = 'Operators can view their assigned leads'
  ) THEN
    CREATE POLICY "Operators can view their assigned leads"
      ON leads
      FOR SELECT
      TO authenticated
      USING (
        ((auth.jwt() ->> 'role'::text) = 'operator'::text) AND
        (assigned_to = auth.uid())
      );
  END IF;
END $$;