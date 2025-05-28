/*
  # Add RLS policies for leads table

  1. Security Changes
    - Add policy for admins to have full access to leads
    - Add policy for sales agents to create and modify their own leads
    - Add policy for operations managers to view all leads
    - Add policy for operators to view their assigned leads

  2. Notes
    - Policies are designed to match the existing role-based access patterns
    - Each role has specific permissions aligned with their responsibilities
*/

-- Policy for admins to have full access
CREATE POLICY "Admins have full access to leads"
ON public.leads
FOR ALL
TO authenticated
USING (
  (auth.jwt() ->> 'role'::text) = 'admin'::text
)
WITH CHECK (
  (auth.jwt() ->> 'role'::text) = 'admin'::text
);

-- Policy for sales agents to create leads
CREATE POLICY "Sales agents can create leads"
ON public.leads
FOR INSERT
TO authenticated
WITH CHECK (
  (auth.jwt() ->> 'role'::text) = 'sales_agent'::text
);

-- Policy for sales agents to modify their assigned leads
CREATE POLICY "Sales agents can modify their assigned leads"
ON public.leads
FOR UPDATE
TO authenticated
USING (
  (auth.jwt() ->> 'role'::text) = 'sales_agent'::text
  AND (
    assigned_to = auth.uid()
    OR created_by = auth.uid()
  )
)
WITH CHECK (
  (auth.jwt() ->> 'role'::text) = 'sales_agent'::text
  AND (
    assigned_to = auth.uid()
    OR created_by = auth.uid()
  )
);

-- Policy for sales agents to view all leads
CREATE POLICY "Sales agents can view all leads"
ON public.leads
FOR SELECT
TO authenticated
USING (
  (auth.jwt() ->> 'role'::text) = 'sales_agent'::text
);

-- Policy for operations managers to view all leads
CREATE POLICY "Operations managers can view all leads"
ON public.leads
FOR SELECT
TO authenticated
USING (
  (auth.jwt() ->> 'role'::text) = 'operations_manager'::text
);

-- Policy for operators to view their assigned leads
CREATE POLICY "Operators can view their assigned leads"
ON public.leads
FOR SELECT
TO authenticated
USING (
  (auth.jwt() ->> 'role'::text) = 'operator'::text
  AND assigned_to = auth.uid()
);