export type LeadStatus = 'new' | 'negotiation' | 'won' | 'lost';
export type LeadPriority = 'low' | 'medium' | 'high';
export type LeadSource = 'website' | 'referral' | 'direct' | 'other';

export interface Lead {
  id: string;
  customerName: string;
  serviceNeeded: string;
  siteLocation: string;
  status: LeadStatus;
  assignedTo: string;
  createdAt: string;
  updatedAt: string;
  files?: string[];
  notes?: string;
  priority?: LeadPriority;
  source?: LeadSource;
}