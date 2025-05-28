import { supabase } from '../lib/supabase';
import { Lead, LeadStatus } from '../types/lead';

// Get all leads
export const getLeads = async (): Promise<Lead[]> => {
  const { data, error } = await supabase
    .from('leads')
    .select('*')
    .order('created_at', { ascending: false });

  if (error) throw error;
  return data || [];
};

// Get lead by ID
export const getLeadById = async (id: string): Promise<Lead | null> => {
  const { data, error } = await supabase
    .from('leads')
    .select('*')
    .eq('id', id)
    .single();

  if (error) throw error;
  return data;
};

// Create lead
export const createLead = async (lead: Omit<Lead, 'id' | 'createdAt' | 'updatedAt'>): Promise<Lead> => {
  const { data, error } = await supabase
    .from('leads')
    .insert([{
      customer_name: lead.customerName,
      service_needed: lead.serviceNeeded,
      site_location: lead.siteLocation,
      status: lead.status,
      assigned_to: lead.assignedTo,
      notes: lead.notes,
      created_by: lead.createdBy,
      priority: lead.priority,
      source: lead.source
    }])
    .select()
    .single();

  if (error) throw error;
  return {
    id: data.id,
    customerName: data.customer_name,
    serviceNeeded: data.service_needed,
    siteLocation: data.site_location,
    status: data.status,
    assignedTo: data.assigned_to,
    notes: data.notes,
    createdAt: data.created_at,
    updatedAt: data.updated_at,
    createdBy: data.created_by,
    priority: data.priority,
    source: data.source
  };
};

// Update lead
export const updateLead = async (id: string, updates: Partial<Lead>): Promise<Lead | null> => {
  const { data, error } = await supabase
    .from('leads')
    .update({
      customer_name: updates.customerName,
      service_needed: updates.serviceNeeded,
      site_location: updates.siteLocation,
      status: updates.status,
      assigned_to: updates.assignedTo,
      notes: updates.notes,
      priority: updates.priority,
      source: updates.source
    })
    .eq('id', id)
    .select()
    .single();

  if (error) throw error;
  return data ? {
    id: data.id,
    customerName: data.customer_name,
    serviceNeeded: data.service_needed,
    siteLocation: data.site_location,
    status: data.status,
    assignedTo: data.assigned_to,
    notes: data.notes,
    createdAt: data.created_at,
    updatedAt: data.updated_at,
    createdBy: data.created_by,
    priority: data.priority,
    source: data.source
  } : null;
};

// Update lead status
export const updateLeadStatus = async (id: string, status: LeadStatus): Promise<Lead | null> => {
  const { data, error } = await supabase
    .from('leads')
    .update({ status })
    .eq('id', id)
    .select()
    .single();

  if (error) throw error;
  return data ? {
    id: data.id,
    customerName: data.customer_name,
    serviceNeeded: data.service_needed,
    siteLocation: data.site_location,
    status: data.status,
    assignedTo: data.assigned_to,
    notes: data.notes,
    createdAt: data.created_at,
    updatedAt: data.updated_at,
    createdBy: data.created_by,
    priority: data.priority,
    source: data.source
  } : null;
};

// Get leads by status
export const getLeadsByStatus = async (status: LeadStatus): Promise<Lead[]> => {
  const { data, error } = await supabase
    .from('leads')
    .select('*')
    .eq('status', status)
    .order('created_at', { ascending: false });

  if (error) throw error;
  return data ? data.map(lead => ({
    id: lead.id,
    customerName: lead.customer_name,
    serviceNeeded: lead.service_needed,
    siteLocation: lead.site_location,
    status: lead.status,
    assignedTo: lead.assigned_to,
    notes: lead.notes,
    createdAt: lead.created_at,
    updatedAt: lead.updated_at,
    createdBy: lead.created_by,
    priority: lead.priority,
    source: lead.source
  })) : [];
};