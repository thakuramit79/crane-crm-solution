/*
  # Create leads management schema
  
  1. New Tables
    - `leads`
      - `id` (uuid, primary key)
      - `customer_name` (text, required)
      - `service_needed` (text, required)
      - `site_location` (text, required)
      - `status` (text, required)
      - `assigned_to` (uuid, references auth.users)
      - `notes` (text)
      - `created_at` (timestamptz)
      - `updated_at` (timestamptz)
      - `created_by` (uuid, references auth.users)
      - `priority` (text)
      - `source` (text)
  
  2. Security
    - Enable RLS on `leads` table
    - Add policies for:
      - Admins can do everything
      - Sales agents can view all leads and modify their assigned leads
      - Operations managers can view all leads
      - Operators can view only their assigned leads
*/

-- Create leads table
CREATE TABLE IF NOT EXISTS public.leads (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_name text NOT NULL,
  service_needed text NOT NULL,
  site_location text NOT NULL,
  status text NOT NULL CHECK (status IN ('new', 'negotiation', 'won', 'lost')),
  assigned_to uuid REFERENCES auth.users(id),
  notes text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  created_by uuid REFERENCES auth.users(id),
  priority text CHECK (priority IN ('low', 'medium', 'high')),
  source text
);

-- Enable RLS
ALTER TABLE public.leads ENABLE ROW LEVEL SECURITY;

-- Create policies
-- Admin can do everything
CREATE POLICY "Admins have full access"
  ON public.leads
  FOR ALL
  TO authenticated
  USING (
    auth.jwt() ->> 'role' = 'admin'
  );

-- Sales agents can view all leads
CREATE POLICY "Sales agents can view all leads"
  ON public.leads
  FOR SELECT
  TO authenticated
  USING (
    auth.jwt() ->> 'role' = 'sales_agent'
  );

-- Sales agents can modify their assigned leads
CREATE POLICY "Sales agents can modify their assigned leads"
  ON public.leads
  FOR ALL
  TO authenticated
  USING (
    auth.jwt() ->> 'role' = 'sales_agent'
    AND assigned_to = auth.uid()
  );

-- Operations managers can view all leads
CREATE POLICY "Operations managers can view all leads"
  ON public.leads
  FOR SELECT
  TO authenticated
  USING (
    auth.jwt() ->> 'role' = 'operations_manager'
  );

-- Operators can view their assigned leads
CREATE POLICY "Operators can view their assigned leads"
  ON public.leads
  FOR SELECT
  TO authenticated
  USING (
    auth.jwt() ->> 'role' = 'operator'
    AND assigned_to = auth.uid()
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
  BEFORE UPDATE ON public.leads
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();