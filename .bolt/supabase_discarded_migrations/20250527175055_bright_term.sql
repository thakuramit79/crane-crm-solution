/*
  # Create leads table and setup security policies

  1. New Tables
    - `leads`
      - `id` (uuid, primary key)
      - `customer_name` (text)
      - `service_needed` (text)
      - `site_location` (text)
      - `status` (text with check constraint)
      - `assigned_to` (uuid, foreign key to users)
      - `notes` (text, nullable)
      - `created_at` (timestamptz)
      - `updated_at` (timestamptz)
      - `created_by` (uuid, foreign key to users)
      - `priority` (text with check constraint)
      - `source` (text)

  2. Security
    - Enable RLS on leads table
    - Add policies for different user roles:
      - Admins: Full access
      - Operations managers: View all leads
      - Sales agents: View all leads, modify assigned leads
      - Operators: View assigned leads
*/

-- Create leads table
CREATE TABLE IF NOT EXISTS public.leads (
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
  
  -- Add check constraints for status and priority
  CONSTRAINT leads_status_check CHECK (status IN ('new', 'negotiation', 'won', 'lost')),
  CONSTRAINT leads_priority_check CHECK (priority IN ('low', 'medium', 'high'))
);

-- Enable Row Level Security
ALTER TABLE public.leads ENABLE ROW LEVEL SECURITY;

-- Create security policies
CREATE POLICY "Admins have full access"
  ON public.leads
  FOR ALL
  TO authenticated
  USING ((auth.jwt() ->> 'role'::text) = 'admin'::text);

CREATE POLICY "Operations managers can view all leads"
  ON public.leads
  FOR SELECT
  TO authenticated
  USING ((auth.jwt() ->> 'role'::text) = 'operations_manager'::text);

CREATE POLICY "Sales agents can view all leads"
  ON public.leads
  FOR SELECT
  TO authenticated
  USING ((auth.jwt() ->> 'role'::text) = 'sales_agent'::text);

CREATE POLICY "Sales agents can modify their assigned leads"
  ON public.leads
  FOR ALL
  TO authenticated
  USING (
    ((auth.jwt() ->> 'role'::text) = 'sales_agent'::text) AND
    (assigned_to = auth.uid())
  );

CREATE POLICY "Operators can view their assigned leads"
  ON public.leads
  FOR SELECT
  TO authenticated
  USING (
    ((auth.jwt() ->> 'role'::text) = 'operator'::text) AND
    (assigned_to = auth.uid())
  );