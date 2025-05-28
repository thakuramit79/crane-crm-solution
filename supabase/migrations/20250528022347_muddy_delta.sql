/*
  # Add updated_at trigger functionality
  
  1. Changes
    - Creates update_updated_at_column() function if it doesn't exist
    - Creates update_leads_updated_at trigger if it doesn't exist
  
  2. Notes
    - Uses safe CREATE OR REPLACE for function
    - Uses conditional logic for trigger creation
*/

-- Create or replace the updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger only if it doesn't exist
DO $$
DECLARE
  trigger_exists boolean;
BEGIN
  SELECT EXISTS (
    SELECT 1
    FROM pg_trigger
    WHERE tgname = 'update_leads_updated_at'
  ) INTO trigger_exists;
  
  IF NOT trigger_exists THEN
    CREATE TRIGGER update_leads_updated_at
      BEFORE UPDATE ON public.leads
      FOR EACH ROW
      EXECUTE FUNCTION update_updated_at_column();
  END IF;
END $$;