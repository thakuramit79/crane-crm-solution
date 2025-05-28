/*
  # Fresh leads table setup
  
  1. New Tables
    - Recreate leads table with proper schema
      - id (uuid, primary key)
      - customer_name (text)
      - service_needed (text) 
      - site_location (text)
      - status (text with check constraint)
      - assigned_to (uuid, foreign key)
      - notes (text)
      - created_at (timestamptz)
      - updated_at (timestamptz)
      - created_by (uuid, foreign key)
      - priority (text with check constraint)
      - source (text)
  
  2. Security
    - Enable RLS
    - Add policies for different roles
    - Set up foreign key constraints
  
  3. Triggers
    - Add updated_at trigger
*/

-- Drop existing table if it exists
DROP TABLE IF EXISTS leads;

-- Create fresh leads table
CREATE TABLE leads (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_name text NOT NULL,
  service_needed text NOT NULL,
  site_location text NOT NULL,
  status text NOT NULL,
  assigned_to uuid REFERENCES auth.users(id),
  notes text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  created_by uuid REFERENCES auth.users(id),
  priority text,
  source text,
  
  -- Add constraints
  CONSTRAINT leads_status_check CHECK (status IN ('new', 'negotiation', 'won', 'lost')),
  CONSTRAINT leads_priority_check CHECK (priority IS NULL OR priority IN ('low', 'medium', 'high'))
);

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_leads_updated_at
  BEFORE UPDATE ON leads
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Enable RLS
ALTER TABLE leads ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "Admins have full access"
  ON leads
  FOR ALL
  TO authenticated
  USING ((auth.jwt() ->> 'role'::text) = 'admin'::text);

CREATE POLICY "Operations managers can view all leads"
  ON leads
  FOR SELECT
  TO authenticated
  USING ((auth.jwt() ->> 'role'::text) = 'operations_manager'::text);

CREATE POLICY "Sales agents can view all leads"
  ON leads
  FOR SELECT
  TO authenticated
  USING ((auth.jwt() ->> 'role'::text) = 'sales_agent'::text);

CREATE POLICY "Sales agents can modify their assigned leads"
  ON leads
  FOR ALL
  TO authenticated
  USING (
    ((auth.jwt() ->> 'role'::text) = 'sales_agent'::text) AND
    (assigned_to = auth.uid())
  );

CREATE POLICY "Operators can view their assigned leads"
  ON leads
  FOR SELECT
  TO authenticated
  USING (
    ((auth.jwt() ->> 'role'::text) = 'operator'::text) AND
    (assigned_to = auth.uid())
  );