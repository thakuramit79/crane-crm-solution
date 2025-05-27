import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://mihhehjdoyncyfczefnv.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1paGhlaGpkb3luY3lmY3plZm52Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDgzMzk5NDAsImV4cCI6MjA2MzkxNTk0MH0.GuMABzSXxIu7q3hTu6mMEnikiRoFha4BTnM2zxoBCt8';

export const supabase = createClient(supabaseUrl, supabaseAnonKey);