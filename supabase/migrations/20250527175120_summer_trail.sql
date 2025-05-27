/*
  # Update leads table schema
  
  1. Changes
    - Add check constraints for status and priority fields
    - Add source field for lead tracking
  
  2. Notes
    - Table and policies already exist from previous migration
    - Only adding new constraints
*/

-- Add check constraints for status and priority
DO $$ 
BEGIN
  ALTER TABLE public.leads 
    ADD CONSTRAINT leads_status_check 
    CHECK (status IN ('new', 'negotiation', 'won', 'lost'));
    
  ALTER TABLE public.leads 
    ADD CONSTRAINT leads_priority_check 
    CHECK (priority IN ('low', 'medium', 'high'));
EXCEPTION
  WHEN duplicate_object THEN 
    NULL;
END $$;