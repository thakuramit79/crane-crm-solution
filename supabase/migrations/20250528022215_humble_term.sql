/*
  # Add updated_at trigger function
  
  1. Changes
    - Create trigger function for updating updated_at column
    - Add trigger function only if it doesn't exist
*/

-- Create updated_at trigger function if it doesn't exist
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'update_updated_at_column') THEN
    CREATE FUNCTION update_updated_at_column()
    RETURNS TRIGGER AS $$
    BEGIN
      NEW.updated_at = now();
      RETURN NEW;
    END;
    $$ language 'plpgsql';
  END IF;
END $$;

-- Create trigger only if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_trigger
    WHERE tgname = 'update_leads_updated_at'
  ) THEN
    CREATE TRIGGER update_leads_updated_at
      BEFORE UPDATE ON public.leads
      FOR EACH ROW
      EXECUTE FUNCTION update_updated_at_column();
  END IF;
END $$;